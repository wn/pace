//
//  GraphModeSelectController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class GraphModeSelectController: UIViewController {
    @IBOutlet var optionsCollectionView: UICollectionView!
    @IBOutlet private var cancelButton: UIButton!
    private var selectedMode: GraphComparisonMode?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedMode = nil
    }

    @IBAction func segueBack(_ sender: Any) {
        performSegue(withIdentifier: Identifiers.unwindToRunAnalysisSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedMode = selectedMode,
            let runAnalysis = segue.destination as? RunAnalysisController else {
            return
        }
        runAnalysis.changeGraphMode(selectedMode)
    }
}

extension GraphModeSelectController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: optionsCollectionView.frame.width,
                      height: optionsCollectionView.frame.height / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: 10,
                            bottom: 0,
                            right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GraphComparisonMode.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.modeViewCell,
                                                      for: indexPath) as! ModeViewCell
        let modes = GraphComparisonMode.allCases
        let hasBorder = indexPath.item < modes.count - 1
        cell.setBorder(hasBorder)
        cell.label = modes[indexPath.item].rawValue
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMode = GraphComparisonMode.allCases[indexPath.item]
        performSegue(withIdentifier: Identifiers.unwindToRunAnalysisSegue, sender: nil)
    }
}

class ModeViewCell: UICollectionViewCell {
    @IBOutlet private var modeLabel: UILabel!
    @IBOutlet private var border: UIView!

    func setBorder(_ hasBorder: Bool) {
        border.isHidden = !hasBorder
    }

    var label: String? {
        get {
            return modeLabel.text
        }
        set {
            modeLabel.text = newValue
        }
    }
}
