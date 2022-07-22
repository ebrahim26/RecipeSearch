//
//  RecipeTableViewCell.swift
//  RecipeSearch
//
//  Created by Ebrahim abdelhamid on 20/07/2022.
//

import UIKit
import Kingfisher

class RecipeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeSource: UILabel!
    
    @IBOutlet weak var recipeHealthLabel: UILabel!
    var recipeListCellViewModel : RecipeCellViewModel? {
           didSet {
            recipeTitle.text = recipeListCellViewModel?.title
               recipeSource.text = recipeListCellViewModel?.Source
               let urls = URL(string:recipeListCellViewModel?.image_url ?? "")
            recipeImage.kf.setImage(with: urls!,placeholder: UIImage(named:"profileImage"))
            recipeImage.kf.indicatorType = .activity
               recipeHealthLabel.text = recipeListCellViewModel?.healthLabel.joined(separator: ", ")
           }
       }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
