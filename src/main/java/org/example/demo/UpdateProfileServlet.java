package org.example.demo;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String newBio = request.getParameter("bio");
        String newProfilePicture = request.getParameter("profilePictureUrl");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String updateQuery = "UPDATE user_profiles SET bio = ?, profile_picture_url = ? WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateQuery)) {
                stmt.setString(1, newBio);
                stmt.setString(2, newProfilePicture);
                stmt.setInt(3, userId);

                int rowsUpdated = stmt.executeUpdate();
                if (rowsUpdated > 0) {
                    System.out.println("Profile updated successfully.");
                } else {
                    System.out.println("No profile found for user ID: " + userId);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("editProfile.jsp");
    }
}
