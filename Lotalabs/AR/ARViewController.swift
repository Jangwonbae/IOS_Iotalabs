
import RealityKit
import MaterialComponents.MaterialButtons
import CoreLocation
import ARKit
import ARCL
import RealmSwift
class ARViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    //@IBOutlet weak var arkit: ARView!
    let floatingButton = MDCFloatingButton() // 종료
    let floatingButton_s = MDCFloatingButton() // 캡쳐
    let boxAnchor = try! TestAR.loadBox()
    var sceneLocationView = SceneLocationView()
    var AR_inside :Bool = false
    var str_latitude : String = ""
    var str_longitude : String = ""
    var ar_chek :Bool = true // ar 중복방지
    var timer : Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //진북 보정
        sceneLocationView.moveSceneHeadingClockwise()
        sceneLocationView.moveSceneHeadingAntiClockwise()
        
        //동작
        sceneLocationView.run()
        view1 = sceneLocationView
        view = view1
        
        setFloatingButton_s()
        setFloatingButton()

        startTimer()
    }
    
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      sceneLocationView.frame = view.bounds
    }
    
    
    func startTimer(){
        //기존에 타이머 동작중이면 중지 처리
        if timer != nil && timer!.isValid {
            timer!.invalidate()
        }
            
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(createAR), userInfo: nil, repeats: true)
    }
    
    @objc func createAR() {
        let realm = try! Realm()
        let mydata = realm.objects(me.self)
        //===========================================================================================
        //ar위치정보 추가
                let coordinate = CLLocationCoordinate2D(latitude: 37.214908, longitude: 126.952531)
                let location = CLLocation(coordinate: coordinate, altitude: 10)
        //ar이미지 추가
                let image1: UIImage? = UIImage(named:"pokemon.png")!
        //노드생성
                let annotationNode = LocationAnnotationNode(location: location, image: image1!)
        //============================================================================================
        
        print(mydata[0].AR_place)
        //ar_chek 는 기본값으로 True
        if ar_chek{
            
            if mydata[0].AR_place == "true"{
                    print("AR띄우기!!!!!!!!!!")

            //씬뷰에 노드 추가
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                
                    ar_chek = false
            }
        }
        else{
            if mydata[0].AR_place == "false"{
                print("AR지우기!!!!!!!!!!")
                
                //해당되는 ar노드 지우기
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                  // 1초 후 실행될 부분
                    self.sceneLocationView.removeAllNodes()
                    
                    self.ar_chek = true
                }
                
            }
        }

        
    }

    
    //종료버튼 ar내에서 작동
    func setFloatingButton() {
            let image = UIImage(systemName: "xmark")
            floatingButton.sizeToFit()
            floatingButton.translatesAutoresizingMaskIntoConstraints = false
            floatingButton.setImage(image, for: .normal)
            floatingButton.setImageTintColor(.white, for: .normal)
            floatingButton.backgroundColor = .systemRed
            floatingButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
            view.addSubview(floatingButton)
            view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -80))
            view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -280))
    }
    @objc func tap(_ sender: Any) {
        // 모든 ar 노드 지우기
        sceneLocationView.removeAllNodes()
        //타이머 종료
        timer?.invalidate()
        timer = nil
        floatingButton.removeFromSuperview()
        floatingButton_s.removeFromSuperview()
        self.dismiss(animated:true)
    }
    
    
    
    //스크린샷버튼 ar내에서 작동
    func setFloatingButton_s() {
            let image = UIImage(systemName: "camera.fill")
        floatingButton_s.sizeToFit()
        floatingButton_s.translatesAutoresizingMaskIntoConstraints = false
        floatingButton_s.setImage(image, for: .normal)
        floatingButton_s.setImageTintColor(.white, for: .normal)
        floatingButton_s.backgroundColor = .darkGray
        floatingButton_s.addTarget(self, action: #selector(tap_s), for: .touchUpInside)
            view.addSubview(floatingButton_s)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_s, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -700))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_s, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -20))
        }
    @objc func tap_s(_ sender: Any) {
        //현재 화면 캡쳐 후 저장
        let s_image = sceneLocationView.snapshot()
    
        UIImageWriteToSavedPhotosAlbum(s_image, nil, nil, nil)
        
        //토스트메세지
        self.showToast(message: "사진을 저장하였습니다!!")
    }
    
    
    //토스트 메세지
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: { toastLabel.alpha = 0.0 }, completion: {(isCompleted) in toastLabel.removeFromSuperview() })
        
    }

}

