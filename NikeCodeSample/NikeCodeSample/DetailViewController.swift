//
//  DetailViewController.swift
//  NikeCodeSample
//
//  Created by Mounika Jakkampudi on 2/28/20.
//  Copyright © 2020 Mounika Jakkampudi. All rights reserved.
//

import UIKit
class DetailViewController: UIViewController {

    var strings: [String]?
    var albumInfo: [String: Any]?

    override func loadView() {
        // super.loadView()   // DO NOT CALL SUPER

        self.view = UIView()
        self.view.backgroundColor = UIColor.white
        //Image View
        let imageView = UIImageView()
      //  imageView.contentMode = .scaleAspectFit
       // imageView.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
        //imageView.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        let url = URL(string: albumInfo?["artworkUrl100"] as? String ?? "")
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
            }
        }
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 10.0

        stackView.addArrangedSubview(imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stackView)
        //Constraints
        NSLayoutConstraint.activate([
            stackView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor, constant: 0),
            stackView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor, constant: 0),
               stackView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor),
               stackView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor),
               stackView.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor),
              // stackView.centerYAnchor.constraint(equalTo: self.view.readableContentGuide.centerYAnchor)
           ])
        var genre = ""
        if let genres = albumInfo?["genres"] as? [[String: Any]], genres.count > 0 {
            genre = genres[0]["name"] as? String ?? ""
        }

        strings = [getUnwrappedString(title: "name"), getUnwrappedString(title: "artistName"), genre, getUnwrappedString(title: "releaseDate"), getUnwrappedString(title: "copyright")]

        for string in strings ?? [String]() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = string
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .left
            stackView.addArrangedSubview(label)
        }
        
        let button = UIButton()
        button.setTitle("Go to Album", for: .normal)
        button.addTarget(self, action: #selector(itunesRedirection), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 5.0
        button.clipsToBounds = true
        stackView.addArrangedSubview(button)

                
    }
    
    @objc func itunesRedirection() {
      guard let url = URL(string: albumInfo?["url"] as? String ?? "") else {
        return //be safe
      }

      if #available(iOS 10.0, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
          UIApplication.shared.openURL(url)
      }
    }
    
    func getUnwrappedString(title: String) -> String {
        return albumInfo?[title] as? String ?? ""
    }
}
