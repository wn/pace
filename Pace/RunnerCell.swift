//
//  RunnerCell.swift
//  Pace
//
//  Created by Ang Wei Neng on 4/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RunnerTableViewCell: UITableViewCell {

    @IBOutlet var runnerPosition: UILabel!
    @IBOutlet var runnerName: UILabel!
    @IBOutlet var timeLabel: UILabel!


    func setupCell(pos: Int, name: String, time: Int) {
        var posString = "\(pos)"
        switch pos {
        case 1:
            posString = "🏆"
        case 2:
            posString = "🥈"
        case 3:
            posString = "🥉"
        default:
            break
        }
        runnerPosition.text = posString
        runnerName.text = name
        timeLabel.text = String(format: "%d''%02d'", arguments: [Int(time / 60), time % 60])
    }
}
