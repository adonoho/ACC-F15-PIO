//
//  DetailViewController.swift
//  PIO
//
//  Created by Andrew Donoho on 10/16/15.
//  Copyright © 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

