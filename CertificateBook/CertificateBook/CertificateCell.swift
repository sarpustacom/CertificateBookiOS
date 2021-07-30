//
//  CertificateCell.swift
//  CertificateBook
//
//  Created by Sarp Ünsal on 30.07.2021.
//

import UIKit

class CertificateCell: UITableViewCell {

    @IBOutlet weak var certificateNameText: UILabel!
    @IBOutlet weak var certificateFromText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
