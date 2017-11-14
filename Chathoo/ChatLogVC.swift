//
//  ChatLogVC.swift
//  Chathoo
//
//  Created by Chingoo on 11/13/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatLogVC: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    var user: User? {
        didSet {
            navigationItem.title = user?.username
            observeMessages()
        }
    }

    var messages = [Message]()

    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.userUID else {
            return
        }

        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)

            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in

                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }


                self.messages.append(Message(dictionary: dictionary))

                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })

            }, withCancel: nil)

        }, withCancel: nil)


    }

    let cellId = "cellId"
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive

        setupKeyBoardObservers()
    }

    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()

    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()

        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]

        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let videoUrl = info[UIImagePickerControllerMediaURL] {
            handleVideoSelectedForUrl(url: videoUrl as! NSURL)
        } else {
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }

        dismiss(animated: true, completion: nil)
    }

    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }

        if let selctedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selctedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selctedImage)
            })
        }
    }

    private func handleVideoSelectedForUrl(url: NSURL) {
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!)
            }

            if let videoUrl = metadata?.downloadURL()?.absoluteString {


                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {

                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject,
                                                               "imageWidth": thumbnailImage.size.width as AnyObject,
                                                               "imageHeight": thumbnailImage.size.height as AnyObject,
                                                               "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }

            }

        })

        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }

        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.username
        }

    }

    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {

        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)

            return UIImage(cgImage: thumbnailImage)

        } catch let err {
            print(err)
        }

        return nil
    }


    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)

        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }


    func setupKeyBoardObservers() {
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)

    }

    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {

            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }


    func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }

    func handleKeyboardWillHide(notification: Notification) {
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self

        let message = messages[indexPath.item]

        cell.message = message
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)

        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }


        cell.playButton.isHidden = message.videoUrl == nil


        return cell
    }


    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        if message.fromId == Auth.auth().currentUser?.uid {
            // outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false

        } else {
            // incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }

        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }

    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 80
        let message = messages[indexPath.item]

        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }

        let width = UIScreen.main.bounds.width

        return CGSize(width: width, height: height)
    }

    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 100)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        return rect
    }

    

    @objc func handleSend() {

        let properties: [String: AnyObject] = ["text": inputContainerView.inputTextField.text! as AnyObject]
        sendMessageWithProperties(properties: properties)

    }

    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject,
                                               "imageWidth": image.size.width as AnyObject,
                                               "imageHeight": image.size.height as AnyObject]

        sendMessageWithProperties(properties: properties)
    }

    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.userUID
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))

        var value: [String: AnyObject] = ["toId": toId as AnyObject,
                                          "fromId": fromId as AnyObject,
                                          "timestamp": timestamp]

        properties.forEach({value[$0] = $1})
        childRef.updateChildValues(value) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }

            self.inputContainerView.inputTextField.text = nil

            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key

            userMessagesRef.updateChildValues([messageId: 1])

            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])

        }
    }


    var startingFrame: CGRect?
    var blackBackGroundView: UIView?
    var startingImageView: UIImageView?

    func performZoomInForStartingImageView(startingImageView: UIImageView) {

        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)

        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))


        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackGroundView = UIView(frame: keyWindow.frame)
            blackBackGroundView?.backgroundColor = UIColor.black
            blackBackGroundView?.alpha = 0
            keyWindow.addSubview(blackBackGroundView!)
            keyWindow.addSubview(zoomingImageView)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                // h2 / w2 = h1 / w1
                // h2 = h1 / w2 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                self.blackBackGroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center

            }, completion: { (completed: Bool) in
                //                zoomOutImageView.removeFromSuperview()
            })

        }


    }

    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {

            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackGroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })

        }

    }






}



