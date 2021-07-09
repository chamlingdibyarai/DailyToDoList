//
//  ListCellTableViewCell.swift
//  DailyTodo
//
//  Created by chamlingdibyarai on 06/07/21.
//

import UIKit

class ListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var listTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // UItableviewcell selection color
        let cellBackgroundColorView = UIView()

        cellBackgroundColorView.backgroundColor = .white

        self.selectedBackgroundView = cellBackgroundColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure( list : List){
        listTitleLabel.text = list.title
    }
}
