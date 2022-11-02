import ballerina/http;
import ballerinax/github;

configurable string pat = ?;

type Repository record {|
    string name;
    int stars;
|};

service / on new http:Listener(9090) {
    private final github:Client ghClient;
    private final github:ConnectionConfig config = {auth: {token: pat}};

    function init() returns error? {
        self.ghClient = check createGitHubClient(self.config);
    }

    resource function get repos/[string org](int? noOfRepos) returns Repository[]|error {
        stream<github:Repository, github:Error?> repoStream = check self.ghClient->getRepositories(org, true);
        Repository[]? summary = check from var repo in repoStream
            order by repo.stargazerCount descending
            limit noOfRepos?:5
            select {name: repo.name, stars: repo.stargazerCount ?: 0};
        return summary ?: [];
    }
}

function createGitHubClient(github:ConnectionConfig config) returns github:Client|error {
    return new (config);
}
