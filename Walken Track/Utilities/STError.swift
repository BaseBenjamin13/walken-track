//
//  STError.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/12/24.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access to Health Data"
        case .sharingDenied(_):
            "Need Access to create Health Data"
        case .noData:
            "No Data Found"
        case .unableToCompleteRequest:
            "Unable to Complete Request"
        case .invalidValue:
            "Invalid Value"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Setting > Health > Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Setting > Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time. \n\nPlease try again later or contact suupport."
        case .invalidValue:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}
