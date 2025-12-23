import UIKit
import MatchStatsSDK

class ViewController: UIViewController {
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Match Stats", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        button.addTarget(self, action: #selector(showMatchStats), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc
    private func showMatchStats() {
        // Launch the Unity view provided by the SDK and log the result.
        MatchStatsSDKManager.sharedInstance().launchUnity(from: self)
    }

}

