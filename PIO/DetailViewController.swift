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
    @IBOutlet weak var imageView: UIImageView!

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

            if let imageView = imageView,
                data = item.photo?.fullSize?.data,
                image = UIImage(data: data) {

                    imageView.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UIImagePickerControllerDelegate methods.

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

                imageView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UINavigationControllerDelegate methods.

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {

        print(navigationController)

        if let nc = viewController as? UINavigationController,
            vc =  nc.topViewController as? protocol<UINavigationControllerDelegate> {

                navigationController.delegate = vc
        }
        else if let vc = viewController as? protocol<UINavigationControllerDelegate> {
            navigationController.delegate = vc
        }
        
    }

    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {

        print(navigationController)
        
        if let item = item,
            nc = viewController as? UINavigationController,
            vc = nc.topViewController
            where vc == self && nil == item.photo &&
                UIImagePickerController.isSourceTypeAvailable(.Camera) {

                    let ipc = UIImagePickerController()
                    ipc.delegate = self
                    ipc.sourceType = .Camera

                    presentViewController(ipc, animated: true, completion: nil)
        }
    }
}

func resizeImage(image: UIImage, toSize size: CGSize ) -> UIImage? {

    if round(size.width) > 0.0 && round(size.height) > 0.0 {

        let sizeRatio = size.width / size.height

        var resize = image.size
        let imageRatio = resize.width / resize.height;

        let resizeRatio = imageRatio > sizeRatio ?
            size.width / resize.width : size.height / resize.height;

        resize.width  = round(resize.width  * resizeRatio);
        resize.height = round(resize.height * resizeRatio);
        
        let rect = CGRect(origin: CGPoint(
            x: round((size.width  - resize.width)  / 2.0),
            y: round((size.height - resize.height) / 2.0)),
            size: resize
        )
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);

        image.drawInRect(rect, blendMode: .Normal, alpha: 1.0)

        let image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        return image;
    }
    return nil
}
