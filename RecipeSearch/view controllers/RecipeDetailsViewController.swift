//
//  RecipeDetailsViewController.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 20/07/2022.
//

import UIKit
import Kingfisher
import SafariServices
class RecipeDetailsViewController: UIViewController ,SFSafariViewControllerDelegate {

    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var titleText = ""
    var recipeImage = ""
    var recipeIngredients = [String]()
    var publisherWebsite = ""
    var recipeUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource  = self
        recipeTitle.text = titleText
        
    }
    

    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
  
        share(message: recipeUrl, link: recipeUrl)
    }
    
    @IBAction func openWebsiteAction(_ sender: UIButton) {
        if let url = URL(string: publisherWebsite) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self

            present(vc, animated: true)
        }
        }
    
    
    func share(message: String, link: String) {
        if let link = NSURL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension RecipeDetailsViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellImage", for: indexPath) as? RecipeDetailsTableViewCell else {
                    fatalError("Cell not exists in storyboard")
                
                }
//            let url = URL(string:recipeDetailsObject.image_url ?? "")
//            cell.imageView?.kf.setImage(with: url)
            let urls = URL(string:recipeImage)
            cell.imageView?.kf.setImage(with: urls)
            cell.imageView?.kf.indicatorType = .activity
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = recipeIngredients[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return recipeIngredients.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }else{
           return "Ingrident"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
        return 30
        }
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 183.0
//        }else {
//            return 40.0
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 183.0
//        }else {
//            return
//        }
//    }
}
