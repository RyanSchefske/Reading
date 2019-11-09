//
//  ChoicesCell.swift
//  Reader
//
//  Created by Ryan Schefske on 10/13/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowOpacity = 1
        
        let strokeTextAttributes = [
            NSAttributedString.Key.foregroundColor : Colors().buttonColor,
            NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 30) ?? UIFont.systemFont(ofSize: 30)]
        as [NSAttributedString.Key : Any]
        
        titleLabel = {
            let label = UILabel()
            label.text = "Read"
            label.attributedText = NSMutableAttributedString(string: label.text!, attributes: strokeTextAttributes)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: contentView.frame.height / 4).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}

class ReadCell: BaseCell {
    var readingLabel = UILabel()
    let readingText = "Have your text displayed like this"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setupRead()
    }
    
    func setupRead() {
        readingLabel = {
            let label = UILabel(frame: CGRect(x: contentView.center.x, y: contentView.center.y, width: self.readingText.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 24)), height: 30))
            label.text = readingText
            label.textColor = .black
            label.font = label.font.withSize(24)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        contentView.addSubview(readingLabel)
        
        readingLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        readingLabel.rightAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        
        animateRead()
    }
    
    func animateRead() {
        UIView.animate(withDuration: 5, delay: 0, options: .curveLinear, animations: {
            self.readingLabel.frame.origin.x -= self.contentView.frame.width * 2
        }, completion: { (complete) in
            if complete {
                self.readingLabel.frame = CGRect(x: self.contentView.center.x, y: self.contentView.center.y, width: self.readingText.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 24)), height: 30)
                self.readingLabel.rightAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                self.animateRead()
            } else {
                self.readingLabel.rightAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
                self.animateRead()
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpeedCell: BaseCell {
    var readingLabel = UILabel()
    let words = "Have your text displayed like this".components(separatedBy: " ")
    var timer = Timer()
    var counter = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSpeed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSpeed() {
        readingLabel = {
            let label = UILabel(frame: CGRect(x: contentView.center.x, y: contentView.center.y, width: contentView.frame.width, height: 30))
            label.text = words[0]
            label.textColor = .black
            label.font = label.font.withSize(24)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        contentView.addSubview(readingLabel)
        
        readingLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        readingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        animateWords()
    }
    
    func animateWords() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(newWord), userInfo: nil, repeats: true)
    }
    
    @objc func newWord() {
        if counter < words.count {
            if words[counter].count > 2 {
                let range = NSRange(location:2,length:1)
                let attributedString = NSMutableAttributedString(string: words[counter], attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 24)!])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors().buttonColor, range: range)
                readingLabel.attributedText = attributedString
            } else {
                readingLabel.text = words[counter]
            }
            
            counter += 1
        } else {
            timer.invalidate()
            counter = 0
            readingLabel.text = ""
            animateWords()
        }
    }
}

class SpeakCell: BaseCell {
    
    var readingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSpeak()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSpeak() {
        readingLabel = {
            let label = UILabel(frame: CGRect(x: contentView.center.x, y: contentView.center.y, width: contentView.frame.width, height: 30))
            label.text = "Have your text read out loud to you"
            label.textColor = .black
            label.font = label.font.withSize(20)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        contentView.addSubview(readingLabel)
        
        readingLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        readingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
}
