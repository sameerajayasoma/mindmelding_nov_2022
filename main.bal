import ballerina/http;
import ballerinax/github;

configurable string pat = ?;

type Repository record {|
    string name;
    string url;
    int stars;
|};

service / on new http:Listener(9090) {
    resource function get repos/[string org](int? noOfRepos) returns Repository[]|error {
        github:ConnectionConfig config = {auth: {token: pat}};
        github:Client ghClient = check new (config);
        stream<github:Repository, github:Error?> repoStream = check ghClient->getRepositories(org, true);
        Repository[]? summary = check from var repo in repoStream
            order by repo.stargazerCount descending
            limit noOfRepos ?: 10
            select {name: repo.name, url: repo.url ?: "", stars: repo.stargazerCount ?: 0};
        return summary ?: [];
    }

}
