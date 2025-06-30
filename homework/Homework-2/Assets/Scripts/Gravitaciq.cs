using UnityEngine;

public class Gravitaciq : MonoBehaviour
{
    private Rigidbody2D rigidBody;

    [SerializeField]
    int g;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        rigidBody = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void FixedUpdate()
    {
        rigidBody.AddForce(Vector2.down * g);
    }
}
