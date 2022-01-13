//
//  ChatViewController.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-19.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import PhotosUI
import SDWebImage

class ChatViewController: MessagesViewController, UINavigationControllerDelegate {
    
    // properties
    var isNewConversation = false
    let recipientEmail : String
    var recipientFullName : String
    private var conversationID : String? = nil
    
    private var databaseReference = DatabaseManager.shared
    private var storageReference = StorageManager.shared
    private var messages = [Message]()
    
    
    
    // for demo purposes
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {return nil}
        guard let loggedInUserName = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserName) as? String else {return nil}
        let senderToReturn = Sender(photoURLAsString: "", senderId: email, displayName: loggedInUserName) // make sure to update this for the photoURL
        print("Statements are below")
        print(email)
        print(loggedInUserName)
        print(senderToReturn)
        print("Statements are above")
        return senderToReturn
    }
    
    
    //MARK: - Initializers
    init(with email : String, with fullName : String, convoID : String? = nil) {
        self.recipientEmail = email
        self.recipientFullName = fullName
        self.conversationID = convoID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //MARK: - UI Functions
    private func setupInputButton()
    {
        let attachAttachmentsButton = InputBarButtonItem()
        attachAttachmentsButton.setSize(CGSize(width: 35, height: 35), animated: false)
        attachAttachmentsButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachAttachmentsButton.onTouchUpInside {[weak self] _ in
            guard let strongSelf = self else{return}
            strongSelf.presentActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([attachAttachmentsButton], forStack: .left, animated: false)
        
    }
    
    private func presentActionSheet()
    {
        // create and present action sheet
        let actionSheet = UIAlertController(title: "Please choose an attachment", message: "Please pick one of the following options", preferredStyle: .actionSheet)
        let actionSheetPictureButton = UIAlertAction(title: "Attach Pictures", style: .default) { [weak self] _ in
            guard let strongSelf = self else {return}
            // call the code that will bring up the PHPicker and configuration method
            strongSelf.initializeAndPresentPHPicker()
        }
        let actionSheetVideoButton = UIAlertAction(title: "Attach Videos", style: .default) { [weak self] _ in
            guard let strongSelf = self else {return}
            // here we need to present the image picker which will be used to display videos
            strongSelf.initializeAndPresentImagePicker()
        }
        let actionSheetAudioButton = UIAlertAction(title: "Attach Audio", style: .default) { [weak self] _ in
            guard let strongSelf = self else {return}
            // here is where we want to send an audio message
        }
        
        let actionSheetCancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addActions(actions: actionSheetPictureButton, actionSheetVideoButton, actionSheetCancelButton)
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: -  System called functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    
    // MARK: - Functions
    private func initializeVC()
    {
        title = recipientFullName
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        becomeFirstResponder()
        setupInputButton()
        if let safeConversationID = conversationID
        {
            listenForMessages(with: safeConversationID)
        }
    }
    
    private func listenForMessages(with safeConvoID : String)
    {
        databaseReference.getAllMessagesForConversation(with: safeConvoID) {[weak self] result in
            guard let strongSelf = self else {return}
            switch result
            {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("messages array is empty")
                    return
                }
                // messages array is not empty
                strongSelf.messages = messages
                DispatchQueue.main.async {
                    if(messages.count == 1)
                    {
                        // this is so we do not get snapping glitch
                        self?.messagesCollectionView.reloadData()
                    }
                    else
                    {
                        // here this means there is more than one message so we want the newer messages to show and the older messages to go up.
                        self?.messagesCollectionView.reloadDataAndKeepOffset()
                    }
                }
           
            case .failure(let error):
                print("There was an error in getting all the messages for the given conversation:\(error)")
            }
        }
    }
    
    private func initializeAndPresentPHPicker()
    {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 3
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func initializeAndPresentImagePicker()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = false
        picker.videoQuality = .typeMedium
        self.present(picker, animated: true, completion: nil)
    }
}

//MARK: - Extensions
extension ChatViewController : MessagesLayoutDelegate, MessagesDisplayDelegate, MessagesDataSource
{
    func currentSender() -> SenderType {
        if let safeSender = selfSender
        {
            return safeSender
        }
        fatalError("Self Sender is nil which means that the email is not cached")
        /*
         So here if selfSender is nil we ar going to throw a fatalError and return a dummy sender object as we still need to return an object that is of SenderType for this function. However with the fatalError ther return statement will never get executed. So it is just there for compiling purposes.
         */
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
        /**
         So the reason why we are using section is because the MessageKit framework uses sections to seperate every single message. The reason why they do it internally is because a message on screen can have multple pieces like a date time that appears under the message and other data as well. It is cleaner to implement this as a single section per message
         */
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
    {
        // so we want to download the image and then cache it so we do not have to download the same image again and again with every new lifecycle
        guard let message = message as? Message else {return}
        switch message.kind
        {
        case .photo(let mediaItem):
            guard let url = mediaItem.url else {return}
            imageView.sd_setImage(with: url, completed: nil)
            
        default :
            print("default block is getting hit")
        }
    }
}

extension ChatViewController : MessageCellDelegate
{
    func didTapImage(in cell: MessageCollectionViewCell)
    {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let messageSelcted = messages[indexPath.section]
        switch messageSelcted.kind
        {
        case.photo(let mediaItem):
            guard let url = mediaItem.url else {return}
            let vc = PhotoViewerViewController(urlToUse: url)
            navigationController?.pushViewController(vc, animated: true)
            
        case.video(let mediaItem):
            guard let videoURL = mediaItem.url else {return}
            let vc = VideoPlayerViewController(videoToUseURL: videoURL)
            navigationController?.pushViewController(vc, animated: true)
        
        default:
            print("The default block is running and this block should not be running")
        }
    }
    
}


extension ChatViewController : InputBarAccessoryViewDelegate
{
    private func createMessageID() -> String?
    {
        //  so we want to create a unique string everytime this function is called.
        // So the pieces we have to work with are the date, recipientEmail and userEmail. We will also use a random Int to help with the random generation
        let dateString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: Date())
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) else {return nil}
        
        let newIdentifier = "\(recipientEmail)_\(currentUserEmail)_\(dateString)"
        print("created messafge id: \(newIdentifier )")
        return newIdentifier
    }
    

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let safeSelfSender = self.selfSender,
              let messageID = createMessageID() else{return}
        let message = Message(sender: safeSelfSender, messageId: messageID, sentDate: Date(), kind: .text(text)) // this does need to be updated later on to support the various message types
        
        // success so here we want to send message
        if isNewConversation
        {
            // create new conversation in database
            print("Running here because is newConversation is true")
            databaseReference.createNewConversation(with: recipientEmail, otherUserName: recipientFullName, firstMessage: message) {[weak self] result in
                guard let strongSelf = self else {return}
                if result
                {
                    print("Message sent")
                    strongSelf.isNewConversation = false
                    strongSelf.messageInputBar.inputTextView.text = ""
                }
                else
                {
                    print("Failed to send message")
                    // maybe we can alert the user that we have failed to send the message via an alert
                }
            }
        }
        else
        {
            // so here we have to call the method send message to existing conversation
            guard let safeConvoID = conversationID else {return}
            databaseReference.sendMessageToConversation(to: safeConvoID, message: message, recipientName: recipientFullName, recipientEmail: recipientEmail) {[weak self] result in
                guard let strongSelf = self else {return}
                switch result
                {
                case true:
                    // we need to find a way to delete the text
                    print("Successfully sent message to conversation")
                    strongSelf.messageInputBar.inputTextView.text = ""
                case false:
                    print("Failed")
                    // maybe here we can alert the user that we have failed to send the message via an alert
                }
            }
        }
    }
}

// PHPicker Extension
extension ChatViewController : PHPickerViewControllerDelegate
{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("Hello")
        picker.dismiss(animated: true)
        // now we want to run our logic in which we get the objects form the PHPickerResult library so we need to handle two flows of logic and that is we need to handler whether the result is of type image or of type video. We are not supporting live photos at the moment
        guard results.isEmpty == false else {
            print("The user did not select anything.")
            return
        }
        for result in results
        {
            // so now we have to see which object the result is either a photo or video as these are the two types that will require the PHPicker
            if(result.itemProvider.canLoadObject(ofClass: UIImage.self))
            {
                // so here this means we can load an object of UIImage from the result
                result.itemProvider.loadObject(ofClass: UIImage.self) {[weak self] reading, error in
                    guard let strongSelf = self else {return}
                    guard let resultAsImage = reading as? UIImage else {
                        print("Object could not be cast as an image")
                        return
                    }
                    // here this means the reading can be cast as an image
                    guard let data = resultAsImage.pngData() else {
                        print("The data could not be retrieved from the image")
                        return
                    }
                    print(data)
                    // here is where we then want to upload the data to firebase storage.
                    guard let messageID = strongSelf.createMessageID() else {return}
                    guard let safeConversationID = strongSelf.conversationID else {return}
                    
                    
                   // let fileName = "photo_message" + messageID + ".png"
                    let fileName = ("photo_message_\(messageID).png") 
                    strongSelf.storageReference.uploadImageToConversationStorage(data: data, fileName: fileName, conversationID: safeConversationID) { result in
                        switch result
                        {
                        case .success(let downloadURLAsString):
                            print(downloadURLAsString)
                            
                            // now we want to send the message
                            guard let downloadURL = URL(string: downloadURLAsString) else {return}
                            guard let messageID = strongSelf.createMessageID() else {return}
                            guard let safeSelfSender = strongSelf.selfSender else {return}
                            guard let placeHolderImage = UIImage(systemName: "questionmark") else {return}
                            let mediaObj = Media(url: downloadURL, image: nil, placeholderImage: placeHolderImage, size: CGSize(width: 0, height: 0))
                            let message = Message(sender: safeSelfSender, messageId: messageID, sentDate: Date(), kind: .photo(mediaObj))
                            
                            strongSelf.databaseReference.sendMessageToConversation(to: safeConversationID, message: message, recipientName: strongSelf.recipientFullName, recipientEmail: strongSelf.recipientEmail) { result in
                                switch result
                                {
                                case true:
                                    print("Success in sending message with photo ")
                                case false:
                                    print("Failure in sending message with photo")
                                }
                            }
                            
                        // if we reach this case this means that we were not successful in uploading the image to the conversation storage
                        case .failure(let error):
                            print("Error in uploading the image to conversation storage.")
                        }
                    }
                }
            }
            
        }
    }
}

extension ChatViewController : UIImagePickerControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // code for cancel operation
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // we ned to dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
        
        // so here we have finished picking the video we want to get the url for it
        if let videoURL = info[.mediaURL] as? URL
        {
            //success so here the url for the video was extracted
            let messageID = createMessageID()
            let fileName = "video_message_\(messageID).mov"
            // now we have to call our function that will upload our video message to Firebase Storage
            guard let safeConversationID = conversationID else {return}
            storageReference.uploadVideoToConversationStorage(videoURL: videoURL, fileName: fileName, conversationID: safeConversationID) {[weak self] result in
                guard let strongSelf = self else {return}
                switch result
                {
                case .success(let downloadURL):
                    guard let messageID = strongSelf.createMessageID() else {return}
                    guard let safeSelfSender = strongSelf.selfSender else {return}
                    guard let safePlaceHolderImage = UIImage(systemName: "video.circle.fill") else {return}
                    guard let downloadURLAsURL = URL(string: downloadURL) else {return}
                    let mediaObj = Media(url: downloadURLAsURL, image: nil, placeholderImage: safePlaceHolderImage, size: CGSize(width: 300, height: 300))
                    let message = Message(sender: safeSelfSender, messageId: messageID, sentDate: Date(), kind: .video(mediaObj))
                    
                    strongSelf.databaseReference.sendMessageToConversation(to: safeConversationID, message: message, recipientName: strongSelf.recipientFullName, recipientEmail: strongSelf.recipientEmail) { result in
                        switch result
                        {
                        case true :
                            print("Success in sending video message to the recipient")
                        case false:
                            print("Failure in sending the video message to the recipient")
                        }
                    }
                    
                case .failure(let error):
                    print("Error in  uploading the video URL to firebase storage :\(error)")
                    // should make an error enum that displays error message to the user rather than just printing
                }
            }
            
        }
    }
    
    
}
