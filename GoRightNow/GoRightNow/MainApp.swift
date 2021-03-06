//
// Created by jeonggyunyun on 2022/05/18.
//

import SwiftUI
import MapKit

struct MainApp: View {
    @EnvironmentObject var modelView: GoRightNowModelView;
    @EnvironmentObject var selectView: ViewSelect;
    @EnvironmentObject var plannerModelView: PlannerModelView;
    @EnvironmentObject var bottomSheetModelView: BottomSheetModelView;
    @EnvironmentObject var mapModelView: MapModelView
    @State private var isSheetPresented = true
//    @State private var isDetailSheet = true     //값 변경하기

    var body: some View {
        ZStack {
            if (modelView.isNotGotData()) {
                LoadingView()
            } else {
                ZStack {
                    MapView()
                            .bottomSheet(bottomSheetPosition: $bottomSheetModelView.model.bottomSheetPosition,
                                    options: [.appleScrollBehavior],
                                    headerContent: {
                                        BottomSheetHeader(bottomSheetView: bottomSheetModelView, modelView: modelView)
                                    }) {
                                CountryList(countries: modelView.model.countryList)
                            }
                            .sheet(isPresented: $mapModelView.model.isDetailSheet) {

                                if let countryInfo = mapModelView.model.selectedCountry {
                                    CountryDetailView(
                                            countryName: countryInfo.name,
                                            immigInfo: countryInfo.immigInfo,
                                            isoCode: countryInfo.iso_alp2,
                                            imgurl: countryInfo.flagImageURL,
                                            alarmLevel: countryInfo.alarmLevel
                                    )
                                } else {
                                    Text("[Error] No Data")
                                }

                            }
                    if modelView.model.sideMenu {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                SideMenu(menu: $modelView.model.sideMenu, select: $selectView.selectedView, version: modelView.model.version, geometry: geometry)
                                Color.init(red: 0, green: 0, blue: 0, opacity: 0)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // 사이드바 다시 집어 넣기 위한 코드
                                            withAnimation {
                                                if modelView.model.sideMenu {
                                                    modelView.model.sideMenu = !modelView.model.sideMenu
                                                }
                                            }
                                        }
                            }
                        }
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)).animation(.linear(duration: 0.2)))
                                .zIndex(100)
                        // Animation 구현 및 Sidebar가 절대로 뒤에 가지 않도록 설정
                    }
                }

            }
        }

                .onAppear() {
                    modelView.model.sideMenu = false
                    bottomSheetModelView.replacePosDat()
                }
                // 뷰 이동시마다 값을 받아오지 않도록 설정
                .task {
                    if modelView.isNotGotData() {
                        await modelView.getCountryData()        // 국가 list를 받아옴
                        getLocationInfoAndMakeLocationPin(modelView: modelView, mapModelView: mapModelView) { // 국가 위치 정보를 가져와서 Pin를 생성
                            modelView.isGotData(true)
                        }
                    }
                }
                .gesture(sidebarDrag())
    }
    
    func sidebarDrag() -> some Gesture {
        DragGesture()
            .onChanged({gesture in
                if gesture.startLocation.x < CGFloat(100.0){
                    withAnimation {
                        modelView.model.sideMenu = true
                    }
                }
             }
        )
    }
}
