## IAM

<li>

  <ol>IAM Users & Groups</ol>

  <li>
    <ul>IAM Users & Groups via console</ul>
  </li>

1. create an IAM user.

2. go under "Users" and click on "Add users".

3. create a username and that one is going to be "Parvez".

4. enable the password type of credential and we can autogenerate it or create a custom password.

5. don't require a password reset,

6. click on "Next: Permissions".

7. add the user into a group.

8. create a group and this group is going to be called "admin".

9. attach to the "admin" group is called "AdministratorAccess".

10. click on "Tags".

11. click on "Review".

12. create this user.


  <li>
    <ul>IAM Users & Groups via Terraform</ul>
  </li>

# Creating group

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

# Create single user

resource "aws_iam_user" "user" {
  name = "Oishe"
}

# Create Multiple user

resource "aws_iam_user" "example" {
  count = "${length(var.username)}"
  name = "${element(var.username,count.index)}"
  path = "/system/"
}


# add users to a group

resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"
  
  users = [
    aws_iam_user.user.name,
    
  ]

  group = aws_iam_group.developers.name
}

</li> 