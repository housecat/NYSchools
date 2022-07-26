//
//  SchoolsViewController.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/22.
//

import UIKit
import Combine

final class SchoolsViewController: UIViewController {
    private var viewModel:SchoollsViewModel!
    let searchController = UISearchController(searchResultsController: nil)
    var searchQuery: String?
    var cancellables = Set<AnyCancellable>()

    let indicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:60, height:60))
        indicator.style = UIActivityIndicatorView.Style.medium
        return indicator
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    init(viewModel: SchoollsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getSchoolData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New York Schools"
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false

        tableView.delegate = self
        tableView.dataSource = self

        setupSearchBarListener()
        setupLayout()
    }
    
    func setupLayout(){
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
    }
  
    private func setupSearchBarListener() {
      let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification,
                                                           object: searchController.searchBar.searchTextField)

      publisher.map{($0.object as! UISearchTextField).text}
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { searchText in
          print("SEARCH TEXT", searchText)
          self.searchQuery = searchText
          self.viewModel.getSchoolData(from: 0, query: searchText)
        }
        .store(in: &cancellables)
    }
}

extension SchoolsViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.schoolCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = viewModel.school(at: indexPath.row).schoolName
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.checkForAdditionalData(for: indexPath.row, searchQuery: searchQuery)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = viewModel.school(at: indexPath.row)
        navigationController?.pushViewController( DetailsViewController(with: school), animated: true)
    }
}

extension SchoolsViewController:SchoollsViewModelDelegate{
    func schoolsDataUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.indicator.stopAnimating()
            self?.indicator.hidesWhenStopped = true
        }
    }
}


