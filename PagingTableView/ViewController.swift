//
//  ViewController.swift
//  PagingTableView
//
//  Created by Park GilNam on 2020/07/20.
//  Copyright © 2020 swieeft. All rights reserved.
//

import UIKit

struct CellData {
    let title: String
    let date: Date
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var cellDatas: [CellData] = []
    
    var isPaging: Bool = false
    var hasNextPage: Bool = false
    
    var cellHeights: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        paging()
    }
    
    func paging() {
        let index = cellDatas.count
        
        var datas: [CellData] = []
        
        //데이터 생성
        for i in index..<(index + 20) {
            let random = Int.random(in: 1...5)
            
            var title: String = ""
            for j in 0..<random {
                if j == 0 {
                    title = "Title\(i)"
                } else {
                    title = "\(title)\nTitle\(i)"
                }
            }
            
            let data = CellData(title: title, date: Date().addingTimeInterval(TimeInterval(86400 * i)))
            datas.append(data)
        }
        
        //기존 데이터에 새로 생성된 데이터를 붙임
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cellDatas.append(contentsOf: datas)
            
            print(self.cellDatas.count)
            
            //300 이하 까지는 hasNextPage
            self.hasNextPage = self.cellDatas.count > 300 ? false : true
            //paging 끝 flag
            self.isPaging = false
            //reload tableView(tableView 에 로드할 갯수를 파악한 후 그린다, numberOfRowsInSection, cellForRowAt)
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    /*
     동적 셀의 경우 테이블 뷰에서 셀의 높이 계산을 할 때 우선 우리가 정해준 estimatedRowHeight를 기준으로 셀을 그린 후에 데이터에 맞게 높이값을 재정의 합니다.
     
     기본값 으로 정의된 후에 데이터에 맞게 높이값을 재설정 하는 과정에서 높이가 튑니다.
     
     1.각 index 테이블 cell 의 높이를 저장한다.
     2.테이블 높이를 추정할때 각 index 저장한 높이 값을 준다
     
     이렇게 추정후 재설정 과정에서 튀는것을 방지한다.
     */
    
    //*페이징 스크롤 튀는 현상 막기
    //2.테이블 높이를 추정할때 각 index 저장한 높이 값을 준다
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 82
    }
    
    //*페이징 스크롤 튀는 현상 막기
    //1.각 index 테이블 cell 의 높이를 저장한다.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cellDatas.count
        
        //section 이 1 이고, paging 이 시작되었고, 그 다음 페이지가 있다면 section 1 의 로딩인디케이터
        } else if section == 1 && isPaging && hasNextPage {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? MyCell else {
                return UITableViewCell()
            }
            
            let data = cellDatas[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "yyyy. MM. dd"
            
            cell.titleLabel.text = data.title
            cell.dateLabel.text = dateFormatter.string(from: data.date)
            
            return cell
        } else {
        //section 이 1 이 그려진다면 로딩 인디케이터
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else {
                return UITableViewCell()
            }
            
            cell.start()
            
            return cell
        }
    }
}

extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        //offsetY(테이블 뷰 스크롤) 이 (스크롤전체길이 - 현재스크롤 프레임 길이) 보다 위에 있다면 스크롤 끝에 와 있으므로 페이징 한다.
        if offsetY > (contentHeight - height) {
            if isPaging == false && hasNextPage {
                beginPaging()
            }
        }
    }
    
    func beginPaging() {
        //페이징 시작 flag
        isPaging = true

        //isPaging, hasPaging 이 true 인 상태로 테이블뷰의 section 1 을 리로드 해 로딩 인디케이터를 보여줌
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        //페이징 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}

class MyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class LoadingCell: UITableViewCell {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func start() {
        activityIndicatorView.startAnimating()
    }
}
