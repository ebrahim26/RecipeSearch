//
//  RecipeApiCallServices.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 20/07/2022.
//
import Foundation
import Alamofire
import SwiftyJSON
public class APIService  : APIServiceProtocol {
    var recipeArray = [Hit]()
    func getRecipeList( queryParamatter :String,filterType:String,page:Int,cb : @escaping ([Hit]?,Error?) -> () ){
        recipeArray.removeAll()
        var urlString = ""
        if filterType == "all" {
            urlString = "https://api.edamam.com/api/recipes/v2?type=public&q=\(queryParamatter)&app_id=afe6eff3&app_key=ad14cf507be7809f02b8816d775de842".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        }else{
            urlString = "https://api.edamam.com/api/recipes/v2?type=public&q=\(queryParamatter)&app_id=afe6eff3&app_key=ad14cf507be7809f02b8816d775de842&health=\(filterType)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        }
        print(urlString)
        let url = URL(string:urlString)
        AF.request(url! , method: .get, headers: nil ).responseJSON { (response) in

            _ = response.data
            print(response)
            do {
                let json = JSON(response.data!)
                let decoder = JSONDecoder()
               // print(response.value)
                let recipeResponse = try decoder.decode(RecipeResponse.self, from:  response.data!)
                self.recipeArray = recipeResponse.hits ?? []
                 print(json)
                cb( self.recipeArray, nil )


            }catch {
             //   UIViewController.removeSpinner(spinner: sv)
                print("error")
                 cb( []  , response.error)
            }

        }
    }
}
protocol APIServiceProtocol {
    func  getRecipeList(queryParamatter :String, filterType:String,page:Int,cb : @escaping ([Hit]?,Error?) -> () )
}
