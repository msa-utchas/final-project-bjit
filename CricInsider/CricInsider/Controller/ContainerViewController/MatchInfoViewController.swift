//
//  MatchInfoViewController.swift
//  CricInsider
//
//  Created by BJIT on 17/2/23.
//

import UIKit
import Combine
import SDWebImage

class MatchInfoViewController: UIViewController {
    @IBOutlet weak var venueBackgroundView: UIView!
    private var cancelable: Set<AnyCancellable> = []
    let matchInfoViewModel = MatchDetailsViewModel.shared
    var timer = Timer()
    var timerStatus: Bool = false
    
    @IBOutlet weak var matchStatus: UILabel!
    
    @IBOutlet var labelDate: UILabel!
    @IBOutlet weak var teamBImageView: UIImageView!
    @IBOutlet weak var labelLeagueInfo: UILabel!
    @IBOutlet weak var labelTeamBScore: UILabel!
    @IBOutlet weak var labelTeamAScore: UILabel!
    @IBOutlet weak var teamAImageView: UIImageView!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelTeamAName: UILabel!
    @IBOutlet weak var labelTeamBName: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var labelStadiumName: UILabel!
    
    @IBOutlet weak var imageViewStadium: UIImageView!
    @IBOutlet weak var labelCapacity: UILabel!
    @IBOutlet weak var labelCity: UILabel!
    var time: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binder()
        
        labelLeagueInfo.layer.cornerRadius = 8
        labelLeagueInfo.layer.masksToBounds = true
        
        labelType.layer.cornerRadius = 8
        labelType.layer.masksToBounds = true
        // give view background Shadow
        viewBackground.addShadow()
        venueBackgroundView.addShadow()
        
        
    }
    
    
    func binder(){
        matchInfoViewModel.$matchDetails.sink { (id) in
            if let matchDetails = id {
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {return}
                    self.labelTeamAName.text = matchDetails.localTeamName
                    self.labelTeamBName.text = matchDetails.visitorTeamName
                    self.labelType.text = matchDetails.matchType
                    self.teamAImageView.sd_setImage(with: URL(string: matchDetails.localTeamImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
                    self.teamBImageView.sd_setImage(with: URL(string: matchDetails.visitorTeamImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
                    self.labelLeagueInfo.text = matchDetails.leagueName ?? "" + "\n" + "hello0"
                    self.labelTeamAScore.text = String(matchDetails.localTeamRun?.score ?? 0) + "-" + String(matchDetails.localTeamRun?.wickets ?? 0) + "(" + String(matchDetails.localTeamRun?.overs ?? 0.0) + ")"
                    self.labelTeamBScore.text = String(matchDetails.visitorTeamRun?.score ?? 0) + "-" + String(matchDetails.visitorTeamRun?.wickets ?? 0) + "(" + String(matchDetails.visitorTeamRun?.overs ?? 0.0) + ")"
                    self.labelDate.text = matchDetails.date
                    self.labelStadiumName.text = matchDetails.venue?.name ?? "N\\A"
                    self.labelCity.text = matchDetails.venue?.city ?? "N\\A"
                    self.labelCapacity.text = String(matchDetails.venue?.capacity ?? 0)
                    self.imageViewStadium.sd_setImage(with: URL(string: matchDetails.venue?.image_path ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
                    self.matchStatus.text = matchDetails.status
                    if (matchDetails.status == "NS"){
                        self.matchStatus.text = "Upcoming"
                        
                    }
                      
                    if (matchDetails.status == "1st Innings" || matchDetails.status == "2nd Innings" ){
                        if !self.timerStatus{
                            self.startTimer()
                            self.timerStatus = true
                        }
                        
                        
                    }
                    else{
                        self.timer.invalidate()
                    }
                    
                    
                    
                }
                
            }
        }.store(in: &cancelable)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            guard let self = self else {return}
            Task{
                await self.matchInfoViewModel.setMatchDetails(id: self.matchInfoViewModel.matchID!)
                print("hello")
            }
            
            
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("timer Stoped")
  
        timer.invalidate()
    }
    deinit{
        timer.invalidate()
    }
    
}
