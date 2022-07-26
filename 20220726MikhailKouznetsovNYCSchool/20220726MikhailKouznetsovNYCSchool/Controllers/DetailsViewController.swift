//
//  DetailsViewController.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/2022.
//  Copyright © 2022 Mikhail Kouznetsov. All rights reserved.
//

import UIKit
import MapKit

final class DetailsViewController: UIViewController {
    
    private var viewModel:DetailsViewModel!
    private var currentTab:DetailsViewMenu?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mapView, tableView])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let mapView:MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let menu: MKTableMenuView = {
        let menu = MKTableMenuView(height: 50, scrollable: true)
        return menu
    }()
    
    let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.bounces = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    override var title : String? {
        set {
            super.title = newValue
            configureTitleView()
        }
        get {
            return super.title
        }
    }
    
    init( with school:School) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = DetailsViewModel(with:school)
        self.viewModel.delegate = self

        initMapWihLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.getSchoolName()
        
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        menu.delegate = self
        menu.buidMenu([DetailsViewMenu.description.rawValue,
                       DetailsViewMenu.location.rawValue])

        setupLayout()
    }
}

private extension DetailsViewController{
    func setupLayout() {
        view.addSubview(stackView)
        
        let guide = view.safeAreaLayoutGuide
        stackView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        
        mapView.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 0.35).isActive = true
        mapView.isHidden = !viewModel.hasMap()

        tableView.tableHeaderView = menu
    }
    
    func configureTitleView() {
        let someVeryLargeNumber:CGFloat = 4096
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: someVeryLargeNumber, height: someVeryLargeNumber))
        titleLabel.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.tailIndent = -56
        let attrText = NSAttributedString(string: title!, attributes: [NSAttributedString.Key.paragraphStyle : style,
                                                                       NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        titleLabel.attributedText = attrText
        navigationItem.titleView = titleLabel
    }
    
    func initMapWihLocation(){
        guard viewModel.hasMap() else { return }
        let center = viewModel.getSchoolLocationCoordinates()!
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let annotation = MKPointAnnotation()
        annotation.title = viewModel.getSchoolName()
        annotation.coordinate = center
        
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: false)
            self?.mapView.addAnnotation(annotation)
        }
    }
}

extension DetailsViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: currentTab)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentTab! {
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")!
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = viewModel.getSchoolDescription()
            return cell
        case .gpa:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")!
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = viewModel.getGPA(for: indexPath.row)
            return cell
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
            cell.textView.text = viewModel.getGeneralInfo(for: indexPath.row)
            return cell
        }
    }
}

extension DetailsViewController:DetailsViewModelDelegate{
    func menuUpdated(items: [String]) {
        menu.buidMenu(items)
    }
}

extension DetailsViewController:MKTableMenuViewDelegate{
    func menuTabSelected(_ sender: UIButton) {
        currentTab = DetailsViewMenu(rawValue: sender.titleLabel!.text!.lowercased())
        tableView.reloadData()
    }
}

class LocationCell:UITableViewCell{
    let textView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:16).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
