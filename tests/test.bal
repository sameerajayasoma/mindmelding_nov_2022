import ballerinax/github;
import ballerina/http;
import ballerina/test;

@test:Config {}
function foo() returns error? {
    http:Client ghSvcClient = check new ("http://localhost:9090");
    Repository[] actualRepos = check ghSvcClient->get("/repos/ballerina-platform");
    Repository[] expectedRepos = [
        {name: "openapi", stars: 300},
        {name: "ballerina-spec", stars: 200},
        {name: "ballerina-lang", stars: 100}
    ];

    foreach var index in 0 ... 2 {
        test:assertEquals(actualRepos[index], expectedRepos[index]);
    }
}

function getMockResponse() returns stream<github:Repository, github:Error?> {
    GitHubRepoGenerator repGen = new ();
    return new (repGen);
}

class GitHubRepoGenerator {
    int index = -1;
    github:Repository[] repos = [
        {createdAt: "", id: "", name: "ballerina-lang", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 100},
        {createdAt: "", id: "", name: "ballerina-spec", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 200},
        {createdAt: "", id: "", name: "openapi", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 300}
    ];

    public isolated function next() returns record {|github:Repository value;|}|github:Error? {
        self.index += 1;
        if self.index < self.repos.length() {
            return {value: self.repos[self.index]};
        } else {
            return ();
        }
    }
}

@test:Mock {functionName: "createGitHubClient"}
function createMockGitHubClient(github:ConnectionConfig config) returns github:Client|error {
    github:Client ghClient = test:mock(github:Client);
    test:prepare(ghClient).when("getRepositories").thenReturn(getMockResponse());
    return ghClient;
}

