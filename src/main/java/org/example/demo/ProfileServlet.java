package org.example.demo;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // Check if the user is logged in
        if (userId == null) {
            response.sendRedirect("/login");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "SELECT bio, profile_picture_url FROM user_profiles WHERE user_id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            // If user profile is found
            if (rs.next()) {
                String bio = rs.getString("bio");
                String profilePicture = rs.getString("profile_picture_url");

                // Set attributes to forward to the JSP page
                request.setAttribute("bio", bio != null ? bio : "No bio available");
                request.setAttribute("profilePicture", profilePicture != null ? profilePicture : "default_profile_picture.jpg");
            } else {
                // Handle the case where no profile is found
                request.setAttribute("error", "Profile not found.");
            }

            // Forward request to profile.jsp
            request.getRequestDispatcher("profile.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            // Handle the SQL exception, e.g., redirect to an error page
            request.setAttribute("error", "Database error occurred.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
