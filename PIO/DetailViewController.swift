//
//  DetailViewController.swift
//  PIO
//
//  Created by Andrew Donoho on 10/16/15.
//  Copyright © 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var problemField: UITextField!
    @IBOutlet weak var titleField: UITextField!

    var item: Item? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let item = item {
            dateLabel?.text = item.date.description
            doneSwitch?.on = item.done
            problemField?.text = item.problem
            titleField?.text = item.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)

        if let item = item
            where nil == item.photo &&
                UIImagePickerController.isSourceTypeAvailable(.Camera) {

                    let ipc = UIImagePickerController()
                    ipc.delegate = self
                    ipc.sourceType = .Camera

                    presentViewController(ipc, animated: true, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        var metaInfo = info

        if let image = metaInfo.removeValueForKey(UIImagePickerControllerOriginalImage) as? UIImage,
            item = item, moc = item.managedObjectContext {

                let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: moc) as! Photo
                item.photo = photo

                let fullSize = NSEntityDescription.insertNewObjectForEntityForName("FullSize", inManagedObjectContext: moc) as! FullSize
                fullSize.data = UIImageJPEGRepresentation(image, 1.0)
                photo.fullSize = fullSize

                // Save the context.
                do { try moc.save() }
                catch { abort() }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}

