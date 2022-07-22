//
//  RecipeViewModel.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 20/07/2022.
//

import Foundation
import RealmSwift
class RecipeListViewModel {
    
    let apiService: APIServiceProtocol

    private var recipeModelList: [Hit] = [Hit]()
    let realm = try! Realm()
    private var cellViewModels: [RecipeCellViewModel] = [RecipeCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var searchedQuery = [RecipeCellViewModel]()
    var state: State = .error
        
       
    var numberOfCells: Int {
        return cellViewModels.count
    }
    var recipeModel: Hit?

    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch(queryParamatter :String,filterType:String,page:Int) {
        apiService.getRecipeList(queryParamatter :queryParamatter,filterType: filterType,page: page){ [weak self] (recipeList, error) in
            guard let self = self else {
                return
            }

            guard error == nil else {
                self.state = .error
                return
            
            }

            self.processFetchedRecipe(recipeModelList: recipeList!)
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> RecipeCellViewModel {
        return cellViewModels[indexPath.row]
    }
    func getPrevCellViewModel( at indexPath: IndexPath ) -> RecipeCellViewModel {
        return searchedQuery[indexPath.row]
    }
    
    func createCellViewModel( recipeModel: Hit ) -> RecipeCellViewModel {

        return RecipeCellViewModel(healthLabel: recipeModel.recipe?.healthLabels  ?? [], title: recipeModel.recipe?.label ?? "" , Source: recipeModel.recipe?.source ?? "", image_url: recipeModel.recipe?.image ?? "", ingerdientArray: recipeModel.recipe?.ingredientLines ?? [] ,publisherLink: recipeModel.recipe?.url ?? "" ,reciepeUrl: recipeModel.recipe?.shareAs ?? "")
    }
    
    private func processFetchedRecipe( recipeModelList: [Hit] ) {
        self.recipeModelList = recipeModelList // Cache
        var vms = [RecipeCellViewModel]()
        for recipe in recipeModelList {
            vms.append( createCellViewModel(recipeModel: recipe) )
        }
        self.cellViewModels = vms
    }
    
    func saveToDatabase(recipeObject:RecipeCellViewModel){
        let previousSearchObject = RecipeCellSearchClass()
        do {
            let realm = try Realm()
            
            if let obj = realm.objects(RecipeCellSearchClass.self).filter("title = %@",recipeObject.title ).first {
                
                //Delete must be perform in a write transaction
                
                try! realm.write {
                    realm.delete(obj)
                }
            

                
            

            }
            
        } catch let error {
            print("error - \(error.localizedDescription)")
        }
        previousSearchObject.title = recipeObject.title
        previousSearchObject.publisherLink = recipeObject.publisherLink
        previousSearchObject.reciepeUrl = recipeObject.reciepeUrl
        previousSearchObject.image_url = recipeObject.image_url
        previousSearchObject.Source = recipeObject.Source
        //previousSearchObject.a
        previousSearchObject.ingerdientArray.append(objectsIn: recipeObject.ingerdientArray)
        previousSearchObject.healthLabel.append(objectsIn: recipeObject.healthLabel)
//       // previousSearchObject.ingerdientArray =
//        previousSearchObject.healthLabel =
        try! realm.write {
            realm.add(previousSearchObject)
            print("added")
            
        }
      
    }
    func loadDataBase()->[RecipeCellViewModel]{
        do {
            searchedQuery.removeAll()
        let realm = try Realm()
        let previousSearchArray = realm.objects(RecipeCellSearchClass.self)
            print(previousSearchArray.count)
            for i in previousSearchArray {
                var recipeObject = RecipeCellViewModel(healthLabel: i.healthLabel as! [String] , title: i.title, Source:i.Source , image_url:i.image_url , ingerdientArray: i.ingerdientArray as! [String], publisherLink:i.publisherLink , reciepeUrl: i.reciepeUrl)
                
                searchedQuery.append(recipeObject)
            }
         
        }catch let error {
            print("error - \(error.localizedDescription)")
        }
        return searchedQuery
    }
}
