//
//  ViewController.swift
//  ColumnText
//
//  Created by Sureshbabu Naidu on 19/01/17.
//  Copyright © 2017 Vishwak Sol pvt. ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AKOMultiColumnTextViewDataSource {
    @IBOutlet var multiPageTextView: AKOMultiPageTextView!
    var content : String = ""
    var totalPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.multiPageTextView.dataSource = self
        self.multiPageTextView.columnInset = CGPoint(x: 10, y: 10)
        self.multiPageTextView.columnCount = 3
        content = String(describing: [NSString (fromFileNamed: "Next.txt")])
        print(content)
               DispatchQueue.global(qos: .background).async {
         
            DispatchQueue.main.async {
               
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        //let attriButed = self.content.utf8Data?.attributedStringColumnWise
        self.multiPageTextView.text = self.content

//        DispatchQueue.global(qos: .background).async {
//             let attriButed = self.content.utf8Data?.attributedStringColumnWise
//            DispatchQueue.main.async {
//                 self.multiPageTextView.text = attriButed?.string
//            }
//        }
        print(self.multiPageTextView.lastPageIndex)
    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
    override func viewWillDisappear(_ animated: Bool) {
       self.multiPageTextView.dataSource = nil
       self.multiPageTextView.tempScrollview.delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Action Methods
    
    @IBAction func nextAction(_ sender: Any) {
        content = String(describing: [NSString (fromFileNamed: "Next.txt")])
//        print(content)
//        DispatchQueue.global(qos: .background).async {
//            let attriButed = self.content.utf8Data?.attributedString
//            DispatchQueue.main.async {
//                self.multiPageTextView.text = attriButed?.string
//            }
//        }
        self.multiPageTextView.text =  content

    }
    @IBAction func centerAction(_ sender: Any) {
        content = String(describing: [NSString (fromFileNamed: "Center.txt")])
//        print(content)
//        DispatchQueue.global(qos: .background).async {
//            let attriButed = self.content.utf8Data?.attributedString
//            DispatchQueue.main.async {
//                self.multiPageTextView.text = attriButed?.string
//            }
//        }
        self.multiPageTextView.text =  content
    }
    @IBAction func previousAction(_ sender: Any) {
        content = String(describing: [NSString (fromFileNamed: "Previous.txt")])
        print(content)
        DispatchQueue.global(qos: .background).async {
            let attriButed = self.content.utf8Data?.attributedString
            DispatchQueue.main.async {
                self.multiPageTextView.text = attriButed?.string
            }
        }
         print(self.totalPage)
    }
    //MARK: static imageview creation
    func akoMultiColumnTextView(_ textView: AKOMultiColumnTextView!, viewForColumn column: Int, onPage page: Int) -> UIView! {
        totalPage = page
        if page == 0{
            if column == 1{
                let  view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                view.backgroundColor = UIColor.orange
                return view
                
            }else if column == 2{
                let  view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                view.backgroundColor = UIColor.orange
                return view
            }
        }
        return nil
    }
    //MARK: Orientation Check
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape{
             print("Landscape")
             self.multiPageTextView.columnCount = 4
        }else{
           print("Portrait")
             self.multiPageTextView.columnCount = 3
        }
        self.multiPageTextView .setNeedsDisplay()
    }
}
extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    var attributedStringColumnWise: NSMutableAttributedString? {
        do {
            let fontval = UIFont.systemFont(ofSize: 18)
            
            let   attrStr = try NSMutableAttributedString(data: self, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8.rawValue], documentAttributes: nil)
            attrStr.addAttributes([NSFontAttributeName: fontval
                ,NSForegroundColorAttributeName:UIColor.black], range: NSRange(location: 0, length: attrStr.length))
            return attrStr
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
extension String {
    var utf8Data: Data? {
        return data(using: .utf8)
    }
}
