unit uGroupMembershipTests;

interface

uses
  DUnitX.TestFramework, uGMS.Manager, uGMS.Member;

type
  [TestFixture]
  TGroupMembershipTests = class(TObject)
  private
    FGroupMembership: TManager;
    procedure CreateGroupClients;
    procedure CreateGroupEmpty;
    procedure JoinGroupNotExists;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestCreateGroup;
    [Test]
    procedure TestJoin;
  end;

implementation

uses
  System.SysUtils, uGroupMembershipAPI, uGMS.Exceptions, uGMS.Group;

procedure TGroupMembershipTests.CreateGroupClients;
begin
  FGroupMembership.CreateGroup('Clients');
end;

procedure TGroupMembershipTests.CreateGroupEmpty;
begin
  FGroupMembership.CreateGroup(' ');
end;

procedure TGroupMembershipTests.JoinGroupNotExists;
begin
  FGroupMembership.Join('1', '127.0.0.1:501', 0, 'Group not exists');
end;

procedure TGroupMembershipTests.Setup;
begin
  FGroupMembership := TManager.Create;
end;

procedure TGroupMembershipTests.TearDown;
begin
  FreeAndNil(FGroupMembership);
end;


procedure TGroupMembershipTests.TestCreateGroup;
begin
  CreateGroupClients;
  Assert.WillRaise(CreateGroupClients, EGroupDuplicated, 'Group undefined');
  Assert.WillRaise(CreateGroupEmpty, EGroupUndefined, 'Group duplicated');

  FGroupMembership.CreateGroup('Group 1', GROUP_UNLIMITED, gaOpen);
  FGroupMembership.CreateGroup('Group 2', GROUP_UNLIMITED, gaClosed);
  FGroupMembership.CreateGroup('Group 3', GROUP_UNLIMITED, gaRestrict, 'Group 1');
  FGroupMembership.CreateGroup('Group 4', 1);
end;

procedure TGroupMembershipTests.TestJoin;
begin
  FGroupMembership.CreateGroup('Clients', 1);
  FGroupMembership.Join('1', '127.0.0.1:500', 0, 'Clients');

  Assert.WillRaise(JoinGroupNotExists, EGroupNotExists, 'Group not exists.');
end;

initialization
  TDUnitX.RegisterTestFixture(TGroupMembershipTests);

end.
