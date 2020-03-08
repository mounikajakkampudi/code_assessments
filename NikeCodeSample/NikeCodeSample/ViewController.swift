//
//  ViewController.swift
//  NikeCodeSample
//
//  Created by Mounika Jakkampudi on 2/28/20.
//  Copyright © 2020 Mounika Jakkampudi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var tableView: UITableView?
    var albumDict: [[String: Any]]?

    override func loadView() {
        super.loadView()

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
        self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tableView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
        self.tableView = tableView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Top Albums"
        // Do any additional setup after loading the view.
       // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        let URLString = "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json"
        let url = URL(string: URLString)
        let request = URLRequest(url: url!)


        self.execTask(request: request) {[weak self] (ok, obj)  in

            print("I AM BACK \(ok) obj \(String(describing: obj))")
            if let result = obj as? [String: Any], let feed = result["feed"] as? [String: Any] {
            self?.albumDict = feed["results"] as? [[String: Any]] ?? [[String: Any]]()
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
    }
    func execTask(request: URLRequest, taskCallback: @escaping (Bool,
        AnyObject?) -> ()) {

        let session = URLSession(configuration: URLSessionConfiguration.default)
        print("THIS LINE IS PRINTED")
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                print("THIS ONE IS PRINTED, TOO")
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
        })
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumDict?.count ?? 0
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       var cell:UITableViewCell? =
        tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                        reuseIdentifier: "UITableViewCell")
        }

        cell?.separatorInset = UIEdgeInsets.zero
        let item = self.albumDict?[indexPath.item]
        cell?.textLabel?.text = item?["name"] as? String ?? ""
        cell?.detailTextLabel?.text = item?["artistName"] as? String ?? ""
        let url = URL(string: item?["artworkUrl100"] as? String ?? "")
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell?.imageView?.image = UIImage(data: data!)
                cell?.imageView?.contentMode = .scaleAspectFit
                let marginGuide = cell?.contentView.layoutMarginsGuide ?? UILayoutGuide()
                cell?.imageView?.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    (cell?.imageView?.topAnchor.constraint(equalTo: marginGuide.topAnchor) ?? NSLayoutConstraint()),
                    (cell?.imageView?.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor) ?? NSLayoutConstraint()),
                    (cell?.imageView?.leadingAnchor.constraint(equalTo: cell?.contentView.leadingAnchor ?? NSLayoutAnchor(), constant: -40) ?? NSLayoutConstraint())
                    ])
                cell?.setNeedsLayout()
            }
        }
        return cell!
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.albumInfo = self.albumDict?[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
