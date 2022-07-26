//
//  School.swift
//  20220726MikhailKouznetsovNYCSchool
//
//  Created by Mikhail Kouznetsov on 7/26/22.
//

import Foundation

struct School: Codable {
  let dbn: String
  let schoolName: String
  let boro: String
  let overviewParagraph: String
  let academicopportunities1: String?
  let academicopportunities2: String?
  let ellPrograms: String
  let neighborhood: String
  let buildingCode: String?
  let location: String
  let phoneNumber: String
  let faxNumber: String?
  let schoolEmail: String?
  let website: String?
  let subway: String
  let bus: String
  let grades2018: String
  let finalgrades: String
  let totalStudents: String
  let extracurricularActivities: String?
  let schoolSports: String?
  let attendanceRate: String
  let pctStuEnoughVariety: String?
  let pctStuSafe: String?
  let schoolAccessibilityDescription: String?
  let directions1: String?
  let requirement1_1: String?
  let requirement2_1: String?
  let requirement3_1: String?
  let requirement4_1: String?
  let requirement5_1: String?
  let offerRate1: String?
  let program1: String
  let code1: String
  let interest1: String
  let method1: String
  let seats9ge1: String?
  let grade9gefilledflag1: String?
  let grade9geapplicants: String?
  let seats9swd: String?
  let grade9swdfilledflag1: String?
  let grade9swdapplicants1: String?
  let seats101: String?
  let admissionspriority1: String?
  let admissionspriority21: String?
  let admissionspriority31: String?
  let grade9geapplicantsperseat1: String?
  let grade9swdapplicantsperseat1: String?
  let primaryAddressLine1: String
  let city: String
  let zip: String
  let stateCode: String
  let latitude: String?
  let longitude: String?
  let communityBoard: String?
  let councilDistrict: String?
  let censusTract: String?
  let bin: String?
  let bbl: String?
  let nta: String?
  let borough: String?
  
  var gpa:Scores?
}

struct Scores: Codable {
  let dbn: String
  let schoolName: String
  let numOfSatTestTakers: String
  let satCriticalReadingAvgScore: String
  let satMathAvgScore: String
  let satWritingAvgScore: String
}
