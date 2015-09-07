_ = require 'lodash'

Stats = (System) ->
  ActivityItem = System.getModel 'ActivityItem'

  # lol, doesn't even cache
  (req, res, next) ->
    me = System.getMe()

    return next new Error 'Who are you?' unless me.data?.foursquare
    ActivityItem.find
      identity: me._id
      platform: 'foursquare'
    .find (err, items) ->
      if !err and items?.length > 0
        activityItems = items
      result =
        count: items.length

      venuesById = {}
      venueIds = _.uniq _.map items, (item) ->
        if !venuesById[item.data.venue.id]?.count
          venuesById[item.data.venue.id] =
            data: item.data.venue
            name: item.data.venue.name
            count: 0
        venuesById[item.data.venue.id].count++
        item.data.venue.id

      categoriesByName = {}
      categoryNames = _.uniq _.flatten _.map items, (item) ->
        _.map item.data.venue.categories, (cat) ->
          if !categoriesByName[cat.name]?.count
            categoriesByName[cat.name] =
              category: cat
              name: cat.name
              count: 0
          categoriesByName[cat.name].count++
          cat.name

      venues = _.map venueIds, (venueId) ->
        venuesById[venueId]

      topVenues = _.sortBy venues, (venue) -> -venue.count
      topVenues = topVenues.splice 0, 10
      topVenues = _.map topVenues, (venue) ->
        {
          id: venue.data.id
          name: venue.name
          count: venue.count
        }

      categories = _.map categoryNames, (catName) ->
        categoriesByName[catName]
      categories = _.map categories, (cat) ->
        distinctVenues = _.filter venues, (venue) ->
          _.find venue.data.categories, (vc) ->
            vc.name == cat.name
        {
          id: cat.category.id
          name: cat.name
          count: cat.count
          distinct: distinctVenues.length
        }

      topCategories = _.sortBy categories, (cat) -> -cat.count
      topCategories = topCategories.splice 0, 10

      distinctCategories = _.sortBy categories, (cat) -> -cat.distinct
      distinctCategories = distinctCategories.splice 0, 10

      result.venueCount = venues.length
      result.categoryCount = categoryNames.length
      result.topVenues = topVenues
      result.topCategories = topCategories
      result.distinctCategories = distinctCategories

      res.render 'stats',
        foursquareStats: result

module.exports = (System) ->
  routes:
    admin:
      '/admin/foursquare/stats': 'stats'

  handlers:
    stats: Stats System

  globals:
    public:
      nav:
        Admin:
          'Social Networks':
            Foursquare:
              Stats: '/admin/foursquare/stats'
