//
//  DetailsViewModel.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/22.
//

import MapKit
import Foundation
import Combine

public enum DetailsViewMenu: String {
    case description = "description"
    case gpa = "gpa"
    case location = "school info"
}

protocol DetailsViewModelDelegate: AnyObject {
    func menuUpdated( items:[String])
}

protocol DetailsViewModelInterface {
    func getSchoolLocationCoordinates() -> CLLocationCoordinate2D?
    func getSchoolName() -> String
    func getSchoolDescription() -> String
    func getGPA(for row:Int) -> String
    func getGeneralInfo(for row:Int) -> String
    func hasMap() -> Bool
}

final class DetailsViewModel: DetailsViewModelInterface {
    
    weak var delegate: DetailsViewModelDelegate?
    private var school: School
    var cancellables = Set<AnyCancellable>()

    private let takersString = "Total number of takers: "
    private let readingScore = "Critical reading average score: "
    private let mathScore = "Math average score: "
    private let writingScore = "Writing average score: "
    
    init(with school:School) {
        self.school = school
      
        Network.get(endpoint: .schoolData,
                    decodingType: [Scores].self,
                    params: ["dbn": school.dbn])
        .retry(3)
        .compactMap({$0})
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("SCORES ERROR", error.errorDescription)
            }
        } receiveValue: { [weak self] scores in
            guard let gpa = scores.first else { return }
            self?.school.gpa = gpa
            self?.delegate?.menuUpdated(items: [DetailsViewMenu.description.rawValue,
                                                DetailsViewMenu.location.rawValue,
                                                DetailsViewMenu.gpa.rawValue])
        }
        .store(in: &cancellables)
    }
    
    func getSchoolLocationCoordinates() -> CLLocationCoordinate2D? {
        guard let latitudeString = school.latitude,
            let longitudeString = school.longitude,
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString) else {
                return nil
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func getSchoolName() -> String {
        return school.schoolName
    }
    
    func getSchoolDescription() -> String {
        return school.overviewParagraph
    }
    
    func numberOfRows(for currentTab:DetailsViewMenu?) -> Int {
        guard let currentTab = currentTab else { return 0 }
        switch currentTab {
        case .description: return 1
        case .location: return school.schoolEmail == nil ? 3 : 4
        case .gpa: return 4
        }
    }
    
    func getGPA( for row:Int) -> String {
        switch row {
        case 0: return takersString + school.gpa!.numOfSatTestTakers
        case 1: return readingScore + school.gpa!.satCriticalReadingAvgScore
        case 2: return mathScore + school.gpa!.satMathAvgScore
        case 3: return writingScore + school.gpa!.satWritingAvgScore
        default: return ""
        }
    }

    func getGeneralInfo(for row:Int) -> String {
        switch row {
        case 0:
            return String(format:"%@\n%@, %@ %@", school.primaryAddressLine1, school.city, "NY", school.zip)
        case 1:
            return String(format:"%@", school.website ?? "")
        case 2:
            let contactInfo = school.schoolEmail != nil ? String(format:"email: %@", school.schoolEmail!) :
                String(format:"phone: %@", school.phoneNumber)
            return contactInfo
        case 3:
            return String(format:"phone: %@", school.phoneNumber)
        default:
            return ""
        }
    }
    
    func hasMap() -> Bool {
        return school.latitude != nil && school.longitude != nil
    }
}
