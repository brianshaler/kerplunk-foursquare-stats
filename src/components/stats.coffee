_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    stats = @props.foursquareStats ? {}
    DOM.section
      className: 'content'
    ,
      DOM.h2 null, 'Foursquare Stats'
      DOM.h3 null, "Total Checkins: #{stats.count ? ''}"
      DOM.h3 null, "Total Unique Venues: #{stats.venueCount ? ''}"
      DOM.h3 null, 'Top Venues:'
      DOM.div null,
        _.map (stats.topVenues ? []), (venue) ->
          DOM.div
            key: "venue-#{venue.id}"
          ,
            "#{venue.name}: "
            DOM.strong null, venue.count
            ' checkins'
      DOM.h3 null, 'Top Categories'
      DOM.div null,
        _.map (stats.topCategories ? []), (category) ->
          # #{cat.name}: <strong>#{cat.count}</strong> — <em>(<strong>#{cat.distinct}</strong> different places)</em>
          DOM.div
            key: "top-category-#{category.id}"
          ,
            "#{category.name}: "
            DOM.strong null, category.count
            ' - '
            DOM.em null,
              '('
              DOM.strong null, category.distinct
              ' different places)'
      DOM.h3 null, 'Most Distinct Venues Per Category'
      DOM.div null,
        _.map (stats.distinctCategories ? []), (category) ->
          # #{cat.name}: <strong>#{cat.distinct}</strong> places — <em>(<strong>#{cat.count}</strong> total checkins)</em>
          DOM.div
            key: "distinct-category-#{category.id}"
          ,
            "#{category.name}: "
            DOM.strong null, category.distinct
            ' places - '
            DOM.em null,
              '('
              DOM.strong null, category.count
              ' total checkins)'
      #pre null, JSON.stringify stats, null, 2
