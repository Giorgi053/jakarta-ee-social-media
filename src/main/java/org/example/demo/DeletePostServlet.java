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


@WebServlet("/DeletePostServlet")
public class DeletePostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        int postId = Integer.parseInt(request.getParameter("postId"));

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "DELETE FROM posts WHERE post_id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, postId);
                stmt.setInt(2, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    System.out.println("DEBUG: Post deleted successfully!");
                } else {
                    System.out.println("DEBUG: No post found or unauthorized delete attempt.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("dashboard.jsp");
    }
}
