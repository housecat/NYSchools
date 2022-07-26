//
//  SchoolsViewModel.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/22.
//

import Foundation
import Combine

protocol SchoollsViewModelDelegate: AnyObject {
    func schoolsDataUpdated()
}

final class SchoollsViewModel {
    public weak var delegate: SchoollsViewModelDelegate?
    private var isFinalLoadComplete = false
    private var isCurrentloadComplete = true

    private let offset:Int = 20
  
    var cancellables = Set<AnyCancellable>()
    
    var schools: [School] = [] {
        didSet{
            delegate?.schoolsDataUpdated()
        }
    }

    func schoolCount() -> Int {
        return schools.count
    }

    func school(at index: Int) -> School {
        return schools[index]
    }
    
  func checkForAdditionalData( for row:Int, searchQuery: String? = nil) {
        if row > schools.count - Int(offset / 10){
          getSchoolData(from: schools.count, query: searchQuery)
        }
    }
    
    func getSchoolData(from: Int = 0, query: String? = nil) {
        if isCurrentloadComplete {
            isCurrentloadComplete = false
          
            var params: [[String : String]] = []
            params.append(["$offset": "\(from)"])
            params.append(["$limit": "\(offset)"])
            params.append(["$order": "school_name"])
            params.append(["$q": query ?? ""])
            
            Network.get(endpoint: .schools,
                        decodingType: [School].self,
                        paramsArray: params)
              .retry(3)
              .compactMap({$0})
              .sink { [weak self] completion in
                  switch completion {
                  case .finished:
                      break
                  case .failure(let error):
                      print("SCHOLLS ERROR", error.errorDescription)
                  }
                  self?.isCurrentloadComplete = true
              } receiveValue: { [weak self]  schools in
                if query?.isEmpty == false, from == 0 {
                  print("NEW LOAD")
                  self?.schools = schools
                } else {
                  print("ADD LOAD")
                  self?.schools.append(contentsOf: schools)
                }
              }
              .store(in: &cancellables)
        }
    }
}

