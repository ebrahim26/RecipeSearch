//
//  RecipeCellViewModel.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 20/07/2022.
//

import Foundation
import RealmSwift
struct RecipeCellViewModel {

    var healthLabel: [String]
    var title : String
    var Source : String
    var image_url : String
    var ingerdientArray : [String]
    var publisherLink :String
    var reciepeUrl:String
}

public enum State {
    case error
}

struct FilterModel {

    var filterDesignName:String
    var filterApiName : String
    var isChecked : Bool
}

class RecipeCellSearchClass: Object {
    @objc dynamic var healthLabel = ""
    @objc dynamic var title = ""
    @objc dynamic var Source = ""
    @objc dynamic var image_url = ""
    @objc  dynamic  var ingerdientArray = ""
    @objc dynamic var publisherLink = ""
    @objc dynamic var reciepeUrl = ""
    
    override static func primaryKey() -> String? {
              return "title"
          }

}
