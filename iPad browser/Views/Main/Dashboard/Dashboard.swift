//
//  Dashboard.swift
//  Aura
//
//  Created by Caedmon Myers on 12/5/24.
//
import SwiftUI


struct Dashboard: View {
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    
    @AppStorage("launchDashboard") var launchDashboard = false
    
    @State var reloadWidgets = false
    @State var reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
    @State var dashboardWidgets: [DashboardWidget] = loadDashboardWidgets()
    
    @State var draggingResize = false
    
    @State var editingWidgets = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            ForEach(dashboardWidgets.indices, id: \.self) { index in
                let widget = dashboardWidgets[index] // Create a local mutable copy
                if !reloadWidgets {
                //if reloadOneWidget != widget {
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                                .opacity(0.75)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing))
                                .opacity(0.5)
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.25))
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            VStack {
                                if dashboardWidgets[index].title == "Weather" {
                                    WeatherWidgetView()
                                        .cornerRadius(10)
                                }
                            }.offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.0001))
                                .contextMenu(menuItems: {
                                    Text("Change Widget Size")
                                    Divider()
                                    
                                    Button(action: {
                                        updateWidgetSize(index: index, size: CGSize(width: 150, height: 150))
                                    }, label: {
                                        Text("Small")
                                    })
                                    
                                    Button(action: {
                                        updateWidgetSize(index: index, size: CGSize(width: 300, height: 150))
                                    }, label: {
                                        Text("Medium")
                                    })
                                    
                                    Button(action: {
                                        updateWidgetSize(index: index, size: CGSize(width: 300, height: 300))
                                    }, label: {
                                        Text("Large")
                                    })
                                    
                                    Button(action: {
                                        updateWidgetSize(index: index, size: CGSize(width: 550, height: 300))
                                    }, label: {
                                        Text("Extra Large")
                                    })
                                }, preview: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing))
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.25))
                                        
                                        if dashboardWidgets[index].title == "Weather" {
                                            WeatherWidgetView()
                                                .cornerRadius(10)
                                        }
                                    }.frame(width: CGFloat(dashboardWidgets[index].width), height: CGFloat(dashboardWidgets[index].height))
                                })
                        }
                        .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                        
                    }.frame(width: CGFloat(dashboardWidgets[index].width), height: CGFloat(dashboardWidgets[index].height))
                        .gesture(
                            DragGesture()
                            .onChanged { value in
                                if editingWidgets {
                                    var updatedWidget = widget // Make a mutable copy
                                    updatedWidget.xPosition = Double(value.location.x)
                                    updatedWidget.yPosition = Double(value.location.y)
                                    dashboardWidgets[index] = updatedWidget
                                    saveDashboardWidgets(widgets: dashboardWidgets)
                                }
                            }
                            .onEnded({ value in
                                if editingWidgets {
                                    reloadWidgets = true
                                    reloadOneWidget = widget
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                                        reloadWidgets = false
                                        reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
                                    }
                                }
                            })
                        )
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        launchDashboard = false
                    }, label: {
                        Text("Disable Dashboard")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            editingWidgets.toggle()
                        }
                    }, label: {
                        Text(editingWidgets ? "Done": "Edit")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        let newWidget = DashboardWidget(title: "Weather", xPosition: 0.0, yPosition: 0.0, width: 150.0, height: 150.0)
                        dashboardWidgets.append(newWidget)
                        saveDashboardWidgets(widgets: dashboardWidgets)
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                Spacer()
            }
        }.onChange(of: editingWidgets, perform: { value in
            reloadWidgets = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                reloadWidgets = false
            }
        })
    }
    
    func updateWidgetSize(index: Int, size: CGSize) {
        dashboardWidgets[index].width = Double(size.width)
        dashboardWidgets[index].height = Double(size.height)
        saveDashboardWidgets(widgets: dashboardWidgets)
        reloadWidgets = true
        reloadOneWidget = dashboardWidgets[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            reloadWidgets = false
            reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
        }
    }
}

// Helper functions to handle UserDefaults
func loadDashboardWidgets() -> [DashboardWidget] {
    if let data = UserDefaults.standard.data(forKey: "dashboardWidgets") {
        let decoder = JSONDecoder()
        if let widgets = try? decoder.decode([DashboardWidget].self, from: data) {
            return widgets
        }
    }
    return []
}

func saveDashboardWidgets(widgets: [DashboardWidget]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(widgets) {
        UserDefaults.standard.set(data, forKey: "dashboardWidgets")
    }
}


#Preview {
    Dashboard()
}