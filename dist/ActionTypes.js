// Generated by CoffeeScript 1.9.2
(function() {
  var editorActions, entityActions, registerAction, sceneActions;

  editorActions = ['StampPrototype', 'RemoveEntity', 'TransformEntity', 'LinkEntities', 'RequestEntityEditor', 'RegisterTimeline', 'AttachTimeline', 'DetachTimeline', 'SetTimelinePlaybackMethod'];

  sceneActions = ['DeltaTime'];

  entityActions = ['AddChild', 'RemoveChild', 'TransformEntity'];

  registerAction = function(dict, actionType) {
    dict[actionType] = actionType;
    return dict;
  };

  module.exports = [editorActions, sceneActions, entityActions].reduce((function(a, b) {
    return a.concat(b);
  }), []).reduce(registerAction, {});

}).call(this);

//# sourceMappingURL=ActionTypes.js.map
