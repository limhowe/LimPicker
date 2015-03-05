//
//  LimCollectionViewCell.swift
//
//  Created by super on 2/23/15.
//  Copyright (c) 2015 super. All rights reserved.
//

import UIKit

class LimCollectionViewCell: UICollectionViewCell {

    let textLabel: UILabel!
    let imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.backgroundColor = UIColor.clearColor()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
        
        let textFrame = CGRect(x: 0, y: 0, width: 50, height: 45)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.boldSystemFontOfSize(CGFloat(17.0))
        //textLabel.textColor = UIColor(red: CGFloat(0), green: CGFloat(150)/CGFloat(255), blue: CGFloat(1),  alpha: CGFloat(1.0))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.text = "+"
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     internal func styleImage () {
        textLabel.hidden = true
        
        if self.selected == true {
            self.layer.borderWidth = 0.0
            self.layer.borderColor = UIColor.clearColor().CGColor;
        }
    }
    
    internal func styleAddButton() {
        textLabel.hidden = false
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(red: CGFloat(0.26), green: CGFloat(0.26), blue: CGFloat(0.26), alpha: CGFloat(1.0)).CGColor
    }
    
    internal func setSelected(selected : Bool) {
        if(selected){
            self.layer.borderColor = UIColor(red: CGFloat(0.26), green: CGFloat(0.26), blue: CGFloat(0.26), alpha: CGFloat(1.0)).CGColor
            self.layer.borderWidth = 3.0
        }else{
            self.layer.borderColor = UIColor.clearColor().CGColor
            self.layer.borderWidth = 0.0
        }
    }
    

}
