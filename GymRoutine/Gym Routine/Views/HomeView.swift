import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 35) {
                    
                    Spacer().frame(height: 20)
                    
                    Text("GYM ROUTINE")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Image("rat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .shadow(color: Color.red.opacity(0.4), radius: 15)
                    
                    Spacer().frame(height: 20)
                    
                    NavigationLink(destination: ExercisesView()) {
                        Text("Gestión de Ejercicios")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 120/255, green: 30/255, blue: 30/255),
                                        Color(red: 209/255, green: 82/255, blue: 82/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.red.opacity(0.6), radius: 10, x: 0, y: 5)
                    }
                    
                        Text("Gestión de Rutinas")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 100/255, green: 20/255, blue: 20/255),
                                        Color(red: 160/255, green: 40/255, blue: 40/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.red.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .navigationBarHidden(true)
            }
        }
    }

