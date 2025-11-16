module Mateoplanner
  module Actions
    module Admin
      module Sessions
        class New < Mateoplanner::Action
          def handle(_request, response)
            response.headers['content-type'] = 'text/html'
            response.body = render_login_form
          end

          private

          def render_login_form
            <<~HTML
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Admin Login - MateoPlanner</title>
                <link rel="stylesheet" href="/assets/styles.css">
                <style>
                  .login-container {
                    max-width: 400px;
                    margin: 100px auto;
                    padding: 40px;
                  }
                  .login-form {
                    background: white;
                    padding: 40px;
                    border-radius: 12px;
                    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
                  }
                </style>
              </head>
              <body>
                <div class="login-container">
                  <div class="login-form">
                    <h1 style="margin-bottom: 30px; text-align: center; color: #667eea;">Admin Login</h1>
                    <form action="/admin/login" method="POST">
                      <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                      </div>
                      <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" required>
                      </div>
                      <button type="submit" class="btn btn-primary" style="width: 100%;">Login</button>
                    </form>
                    <p style="text-align: center; margin-top: 20px;">
                      <a href="/">Back to Home</a>
                    </p>
                  </div>
                </div>
              </body>
              </html>
            HTML
          end
        end
      end
    end
  end
end
