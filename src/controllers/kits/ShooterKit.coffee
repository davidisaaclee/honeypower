_ = require 'lodash'
Kit = require './Kit'

Character = require '../../model/entities/Character'
Machine = require '../../model/entities/Machine'

class ShooterKit extends Kit
  constructor: () ->
    # TODO: make prototypes
    prototypes = []

    # TODO: make physics
    physics = []

    super 'shooter', prototypes, physics