import Kitura
import KituraWebSocket
import KituraStencil
import KituraSession
import SwiftMetrics
import SwiftMetricsKitura
import SwiftMetricsDash
import Credentials
import CredentialsGoogle

// Create a new router
let router = Router()
router.add(templateEngine: StencilTemplateEngine())
router.all(middleware: BodyParser())

let sm = try SwiftMetrics()
let smk = SwiftMetricsKitura(swiftMetricsInstance: sm)
let monitoring = sm.monitor()
sm.start()
let smd = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)

//DB.deleteDB()
DB.setup()


router.all(middleware: Session(secret: PrivateConstants.sessionSecret, store: Sessions()))


let credentials = Credentials()
let googleCredentials = CredentialsGoogle(clientId: PrivateConstants.clientId,
                                          clientSecret: PrivateConstants.clientSecret,
                                          callbackUrl: PrivateConstants.callbackUrl,
                                          options: [CredentialsGoogleOptions.scope: "profile"])

credentials.register(plugin: googleCredentials)
credentials.options["failureRedirect"] = "/login"

//this is listed as necessary but doesn't seem to be
//router.all("login", middleware: credentials)

router.get("/login",
           handler: credentials.authenticate(credentialsType: googleCredentials.name))

router.get("/oauthcallback",
           handler: credentials.authenticate(credentialsType: googleCredentials.name))

router.get("/oauthcallback") {
  request, response, next in
  _ = try? response.redirect("/")
  next()
}

router.get("logout") {
  request, response, next in
  credentials.logOut(request: request)
  try response.redirect("/")
  next()
}

router.get("/") {
  request, response, next in
  
  var userString: String
  var loginLogout: String
  var loginLogoutLink: String
  
  if let profile = request.userProfile {
    userString = profile.displayName
    loginLogout = "(log out)"
    loginLogoutLink = "./logout"
  } else {
    userString = ""
    loginLogout = "log in"
    loginLogoutLink = "./login"
  }
  
  do {
    try response.render("OurPlace.stencil", context: ["user": userString,
                                                      "loginLogout": loginLogout,
                                                      "loginLogoutLink": loginLogoutLink])
  } catch {
    response.status(.internalServerError)
  }
  next()
}

router.get("/world") {
  request, response, next in
  
  let user = request.userProfile?.id
  response.send(json: World.instance.json(for: user))
  next()
}

router.post("/place_block") {
  request, response, next in
  
  guard let profile = request.userProfile else {
    print("unauthorized")
    response.status(.unauthorized)
    next()
    return
  }
  
  if let body = request.body?.asJSON {
    if var block = body["block"] as? [String: Any], let x = block["x"] as? Int, let y = block["y"] as? Int {
      block["author"] = profile.displayName
      block["authorId"] = profile.id
      if let block = Block.from(json: block) {
        let _ = World.instance.place(x: x, y: y, block: block, authorId: profile.id)
        response.send(json: World.instance.json(for: profile.id))
        next()
        return
      }
    }
  }
  response.status(.internalServerError)
  next()
}

router.get("/assets", middleware: StaticFileServer(path: "./assets"))

router.get("/place_block") {
  request, response, next in
  try response.redirect("/")
  next()
}

router.get("/save") {
  request, response, next in
  if request.userProfile?.id == PrivateConstants.adminId {
    World.instance.save()
  }
  try? response.status(.OK).end()
  next()
}

router.get("/stop_server") {
  request, response, next in
  if request.userProfile?.id == PrivateConstants.adminId {
    World.instance.save()
  }
  try? response.status(.OK).end()
  
  Kitura.stop()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
