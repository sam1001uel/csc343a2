import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
	
	Connection conn;
	
    public Assignment2() throws ClassNotFoundException {
    	
    		Class.forName("org.postgresql.Driver");
           
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
    		try {
            conn = DriverManager.getConnection(url, username, password);
            System.out.println("connected!");
            
            String search_path = "set search_path to parlgov";
    			PreparedStatement ps = conn.prepareStatement(search_path);
    			ps.executeUpdate();
    		
            return true;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
    		try {
    			conn.close();
    			System.out.println("disconnected!");
    			return true;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return false;
        }      
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
    		ElectionCabinetResult result = new ElectionCabinetResult(new ArrayList<Integer>(), new ArrayList<Integer>());
    		try {
    			//get countryId according to countryName
    			
    			//Prepare Statement
        		String getcountryId_query = "select id from country where name = ?"; 
        		PreparedStatement getcountryId_ps = conn.prepareStatement(getcountryId_query);
        		getcountryId_ps.setString(1, countryName);
        		
        		//Result
        		ResultSet getcountryId_rs = getcountryId_ps.executeQuery();
        		while (getcountryId_rs.next()) {
        			int countryId = getcountryId_rs.getInt("id"); 
    			
        			System.out.println(countryId);
        		}
            return null;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return result;
        }     
    		
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        return null;
    }

    public static void main(String[] args) {
    		try {
    			Assignment2 test = new Assignment2();
        		String url = "jdbc:postgresql://localhost:5432/csc343h-leetsz9";
        		
        		boolean test_connected = test.connectDB(url, "leetsz9", "");
        		ElectionCabinetResult test_q3 = test.electionSequence("Franc");
        		
        		boolean test_disconnected = test.disconnectDB();
        		
        		//test Strings
        		//System.out.println (test_connected);
        		//System.out.println(test_disconnected);
        		
    		}
    		catch (ClassNotFoundException e) {
        		System.out.println("Failed to find the JDBC driver");
        }
    		
    }

}

