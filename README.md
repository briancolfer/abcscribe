# README ABCScribe

This application, will help people gain insights into behaviors
It will show the antecedents and consequences of behaviors and by seeing these relationships,
people will better be able to predict and control behaviors

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/brian.colfer/ABCScribe.git
    cd ABCScribe
    ```
2. Install the required packages:
    ```bash
    bundle install
    ```
3. Start the Rails server:
    ```bash
    rails server
    ```
4. Open your web browser and navigate to `http://localhost:3000` to access the application.
5. Run the database migrations:
    ```bash
    rails db:migrate
    ```

6. Seed the database with initial data (optional):
     ```bash
     rails db:seed
     ```
## Data structure

The application uses a relational database to store data about behaviors, antecedents, and consequences. 
   The main models include:
