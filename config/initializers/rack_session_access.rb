if Rails.env.test?
  Rails.application.config.middleware.use RackSessionAccess::Middleware
end