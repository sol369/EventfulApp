//
//  EventDetailViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventDetailViewController: UIViewController {
    
    var event: Event?
    
    //variables that will hold data sent in through previous event controller
    var eventImage = ""
    var eventName = ""
    var eventDescription = ""
    var eventStreet = ""
    var eventCity = ""
    var eventState = ""
    var eventZip = 0
    var eventDate = ""
    var eventKey = ""
    var eventPromo = ""
    var currentEventAttendCount = 0 
    //
    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        let imageURL = URL(string: self.eventImage)
        currentEvent.af_setImage(withURL: imageURL!)
        currentEvent.clipsToBounds = true
        currentEvent.translatesAutoresizingMaskIntoConstraints = false
        currentEvent.contentMode = .scaleAspectFit
        currentEvent.isUserInteractionEnabled = true
        currentEvent.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(tapGestureRecognizer)
        return currentEvent
    }()
    
    
    func handlePromoVid(){
        print("Image tappped")
        let videoLauncher = VideoLauncher()
        videoLauncher.showVideoPlayer()
    }
    
    
    //will show the event name
    lazy var eventNameLabel: UILabel = {
        let currentEventName = UILabel()
        currentEventName.text = self.eventName
        currentEventName.translatesAutoresizingMaskIntoConstraints = false
        return currentEventName
    }()
    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 2
        currentAddressLabel.textColor = UIColor.lightGray
        var firstPartOfAddress = self.eventStreet  + "\n" + self.eventCity + ", " + self.eventState
        var secondPartOfAddress = firstPartOfAddress + " " + String(self.eventZip)
        currentAddressLabel.text = secondPartOfAddress
        currentAddressLabel.font = UIFont(name: currentAddressLabel.font.fontName, size: 12)
        return currentAddressLabel
    }()
    //wil be responsible for creating the description label
    lazy var descriptionLabel : UITextView = {
        let currentDescriptionLabel = UITextView()
        currentDescriptionLabel.isEditable = false
        currentDescriptionLabel.textContainer.maximumNumberOfLines = 0
        currentDescriptionLabel.textColor = UIColor.black
        currentDescriptionLabel.textAlignment = .justified
        currentDescriptionLabel.text = self.eventDescription
        currentDescriptionLabel.font = UIFont(name: (currentDescriptionLabel.font?.fontName)!, size: 12)
        return currentDescriptionLabel
    }()
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setImage(#imageLiteral(resourceName: "commentBubble").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    
    func presentComments(){
        print("Comments button pressed")
        let layout = UICollectionViewFlowLayout()
        let commentsController = CommentsViewController(collectionViewLayout:layout)
        commentsController.eventKey = eventKey
        
        let navController = UINavigationController(rootViewController: commentsController)
        navController.navigationBar.isTranslucent = false
        navController.tabBarItem.title = "Comments"
        self.navigationController?.pushViewController(commentsController, animated: false)
        
    }
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setImage(#imageLiteral(resourceName: "walkingNotFilled").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
    }()
    
    lazy var attendCount : UILabel = {
        let currentAttendCount = UILabel()
        currentAttendCount.textColor = UIColor.black
        var numberAttending = 0
        //numberAttending = AttendService.fethAttendCount(for: self.eventKey)
        let ref = Database.database().reference().child("Attending").child(self.eventKey)

        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            numberAttending += Int(snapshot.childrenCount)
            currentAttendCount.text  = String(numberAttending)

        })
        
        return currentAttendCount
    }()
    
    lazy var commentCount : UILabel = {
        let currentCommentCount = UILabel()
        currentCommentCount.textColor = UIColor.black
        //numberAttending = AttendService.fethAttendCount(for: self.eventKey)
        return currentCommentCount
    }()
    
    
    func handleAttend(){
        print("Handling attend from within cell")
        // 2
        attendingButton.isUserInteractionEnabled = false
        // 3
        
        var isAttending = false
        // 4
        AttendService.setIsAttending(!isAttending, for: self.eventKey) { (success) in
            // 5
            defer {
                self.attendingButton.isUserInteractionEnabled = true
            }
            
            // 6
            guard success else { return }
            
            // 7
            self.event?.currentAttendCount += !isAttending ? 1 : -1
            isAttending = !isAttending}
        
    }
    
    //will add the button to add a video or picture to the story
    lazy var addToStoryButton : UIButton =  {
        let addToStory = UIButton(type: .system)
        addToStory.setImage(#imageLiteral(resourceName: "icons8-Plus-64").withRenderingMode(.alwaysOriginal), for: .normal)
        addToStory.addTarget(self, action: #selector(beginAddToStory), for: .touchUpInside)
        return addToStory
    }()
    
    func beginAddToStory(){
       print("Attempting to load camera")
        let camera = CameraViewController()
        camera.eventKey = self.eventKey
        self.navigationController?.pushViewController(camera, animated: true)
    }
    
    lazy var viewStoryButton : UIView = {
       let viewStoryButton = UIView()
        viewStoryButton.backgroundColor = UIColor.red
        viewStoryButton.isUserInteractionEnabled = true
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewStory))
        viewStoryButton.addGestureRecognizer(tapGesture)
        return viewStoryButton
    }()
    
    func handleViewStory(){
        print("Attempting to view story")
        let eventStory = StoriesViewController()
        eventStory.eventKey = self.eventKey
        present(eventStory, animated: true, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = eventName
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Subviews will be added here
        view.addSubview(currentEventImage)
        view.addSubview(eventNameLabel)
        view.addSubview(addressLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(commentsViewButton)
        view.addSubview(attendingButton)
        view.addSubview(attendCount)
        view.addSubview(commentCount)
        view.addSubview(addToStoryButton)
        view.addSubview(viewStoryButton)
        
        //Constraints will be added here
        _ = currentEventImage.anchor(top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: -305, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: 200)
        _ = eventNameLabel.anchor(top: currentEventImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        _ = addressLabel.anchor(top: eventNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        _ = descriptionLabel.anchor(top: addressLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: 200)
        _ = commentsViewButton.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 20, height: 15)
        _ = attendingButton.anchor(top: descriptionLabel.bottomAnchor, left: commentsViewButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 30)
          _ = attendCount.anchor(top: attendingButton.bottomAnchor, left: commentCount.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        _ = commentCount.anchor(top: commentsViewButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        _ = addToStoryButton.anchor(top: descriptionLabel.bottomAnchor, left: attendingButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 30)
        _ = viewStoryButton.anchor(top: descriptionLabel.bottomAnchor, left: addToStoryButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        viewStoryButton.layer.cornerRadius = 40/2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ref = Database.database().reference().child("Comments").child(self.eventKey)
        
        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            var numberOfComments = 0
             numberOfComments = numberOfComments + Int(snapshot.childrenCount)
            self.commentCount.text  = String(numberOfComments)
            
        })
        
    }
    
    func GoBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
