# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "stimulus-reveal-controller" # @4.1.0
pin "tom-select" # @2.3.1
pin "leader-line" # @1.0.5
pin "sortablejs" # @1.14.0
pin "anim-event" # @1.0.17
pin "popper", to: "popper.js", preload: true
pin "bootstrap", to: "bootstrap.js", preload: true
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
pin "@stimulus-components/reveal", to: "@stimulus-components--reveal.js" # @5.0.0
pin "@stimulus-components/rails-nested-form", to: "@stimulus-components--rails-nested-form.js" # @5.0.0

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/src", under: "src", to: "src"
