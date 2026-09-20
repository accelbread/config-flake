SimpleEventHook {
  name = "device/mute-input-routes",
  after = "device/apply-routes",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-routes" },
    },
  },
  execute = function (event)
    local device = event:get_subject()
    for param in device:iterate_params("Route") do
      local route = param:parse()
      if route.properties.direction == "Input"
         and not (route.properties.props and route.properties.props.mute) then
        device:set_param("Route", Pod.Object {
          "Spa:Pod:Object:Param:Route", "Route",
          index = route.properties.index,
          device = route.properties.device,
          props = Pod.Object {
            "Spa:Pod:Object:Param:Props", "Route",
            mute = true,
          },
          save = false,
        })
      end
    end
  end
}:register()
