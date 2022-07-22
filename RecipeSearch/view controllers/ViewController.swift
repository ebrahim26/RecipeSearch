//
//  ViewController.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 19/07/2022.
//

import UIKit
import Alamofire
import SwiftUI
import RealmSwift
class ViewController: UIViewController {
 
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var recipeTableView: UITableView!
    
    @IBOutlet weak var filterCollection: UICollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var isSearching = false
    
    @IBOutlet weak var collectionConstraint: NSLayoutConstraint!
    //  let realm = try! Realm()
    var hasPreviousSearch = false
    lazy var viewModel: RecipeListViewModel = {
        return RecipeListViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        initVM()
    }
    var queryTextSearch = ""
    var filterValue = "all"
    func initView(){
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
       searchText.delegate = self
        searchText.keyboardType = UIKeyboardType.asciiCapable
        navigationController?.navigationBar.isHidden = true
        activityIndicator.style = .large
        activityIndicator.color = .black
        activityIndicator.isHidden = true
        filterCollection.delegate = self
        filterCollection.dataSource = self
    }
    
    func initVM(){
        //viewModel.initFetch(queryParamatter:"pizza",filterType: "all",page: 1)
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
              //  self?.isSearching = false
                if  self?.viewModel.numberOfCells ?? 0 > 0 {
                self?.hasPreviousSearch = false
                self?.recipeTableView.reloadData()
                    self?.recipeTableView.isHidden = false
                    self?.messageLabel.text = ""
               // self?.view.endEditing(true)
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                }else{
                    self?.hasPreviousSearch = false
                    self?.recipeTableView.isHidden = true
                    self?.messageLabel.text = "there is no result"
                   // self?.view.endEditing(true)
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        viewModel.updateLoadingStatus = { [weak self] () in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                switch self.viewModel.state {
                case  .error:
                    self.recipeTableView.isHidden = true
                    self.messageLabel.text = "error from server or network connection please try agian"
                    self.activityIndicator.stopAnimating()
          
                }
            }
        }

    }
  
    var filterArray:[FilterModel] = [FilterModel(filterDesignName: "all",filterApiName: "all", isChecked: false),FilterModel(filterDesignName: "keto",filterApiName: "keto-friendly", isChecked: false),FilterModel(filterDesignName: "Low Sugar",filterApiName: "low-sugar", isChecked: false),FilterModel(filterDesignName: "vegan",filterApiName: "vegan", isChecked: false)]
 
}

extension ViewController: UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if hasPreviousSearch {
            return " previous search"
        }else{
            return ""
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasPreviousSearch {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RecipeTableViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        let cellVM = viewModel.getPrevCellViewModel(at: indexPath )
        cell.recipeListCellViewModel = cellVM
        cell.selectionStyle = .none
        return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RecipeTableViewCell else {
                fatalError("Cell not exists in storyboard")
            }
            let cellVM = viewModel.getCellViewModel(at: indexPath )
            cell.recipeListCellViewModel = cellVM
            cell.selectionStyle = .none
            return cell
        }
                                                 
                                                 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasPreviousSearch {
            if viewModel.loadDataBase().count > 10 {
                return 10
            }else{
                return viewModel.loadDataBase().count
            }
        }else{
        return  viewModel.numberOfCells
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellVM :RecipeCellViewModel?
        if hasPreviousSearch {
            cellVM = viewModel.getPrevCellViewModel( at: indexPath )
       
        }else{
            cellVM = viewModel.getCellViewModel( at: indexPath )
            viewModel.saveToDatabase(recipeObject:cellVM!)
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "RecipeDetailsViewController") as? RecipeDetailsViewController {
            vc.titleText = cellVM?.title ?? ""
            vc.publisherWebsite = cellVM?.publisherLink ?? ""
            vc.recipeIngredients = cellVM?.ingerdientArray ?? []
            vc.recipeImage = cellVM?.image_url ?? ""
            vc.recipeUrl = cellVM?.reciepeUrl ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.filterArray.count
     }
     

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
     
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! FilterCollectionViewCell
         
         // Use the outlet in our custom class to get a reference to the UILabel in the cell
         cell.filterName.text = self.filterArray[indexPath.row].filterDesignName // The row value is the same as the index of the desired text within the array.
         if filterArray[indexPath.row].isChecked {
             cell.backgroundColor = UIColor(red: 247.0/100.0, green: 204.0/100.0, blue: 70.0/100.0, alpha: 1)
             cell.filterName.textColor  =  UIColor.black
             cell.layer.borderWidth = 1
             cell.layer.borderColor = UIColor.gray.cgColor

         }else{
             cell.backgroundColor =  UIColor.white
             cell.filterName.textColor  =  UIColor.black
             cell.layer.borderWidth = 1
             cell.layer.borderColor = UIColor.gray.cgColor
         }
         cell.layer.cornerRadius = 15
         return cell
     }
     
   
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         filterArray[indexPath.row].isChecked = true
         filterValue = filterArray[indexPath.row].filterApiName
         for i in 0..<filterArray.count {
             if i != indexPath.row {
                 filterArray[i].isChecked = false
             }
         }
         collectionView.reloadData()
         viewModel.initFetch(queryParamatter:queryTextSearch,filterType:filterValue,page: 1)
      //   print("You selected cell #\(indexPath.item)!")
     }
}
extension ViewController : UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.recipeTableView.isHidden = false
        self.messageLabel.text = ""
        if textField == searchText {
            if  searchText.text != "" {
                queryTextSearch = searchText.text ?? ""
                
    viewModel.initFetch(queryParamatter:queryTextSearch,filterType:filterValue ,page: 1)
                hasPreviousSearch = false
                recipeTableView.reloadData()
                collectionConstraint.constant = 52
                activityIndicator.startAnimating()
          } else {
                if !viewModel.loadDataBase().isEmpty {
                   hasPreviousSearch = true
                    collectionConstraint.constant = 0
                    recipeTableView.reloadData()
                }else{
                    hasPreviousSearch = false
                    collectionConstraint.constant = 52
                    recipeTableView.reloadData()
                }
          }
        }
        //}
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.recipeTableView.isHidden = false
        self.messageLabel.text = ""
        if textField == searchText {
            if  searchText.text == "" {
          //      let previousSearchArray = realm.objects(PreviousSearchClass.self)
                if !viewModel.loadDataBase().isEmpty {
                    hasPreviousSearch = true
                    collectionConstraint.constant = 0
                //    isSearching = false
                    recipeTableView.reloadData()
                }else{
                    collectionConstraint.constant = 52
                }
            }
        }
    }
}
